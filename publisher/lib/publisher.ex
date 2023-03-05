defmodule Publisher do
  @moduledoc """
  Publishes weather station data.
  """
  use GenServer

  require Logger

  @default_publication_interval_milliseconds 10_000
  @headers [{"Content-Type", "application/json"}]

  @type publisher_state :: %{
          interval: integer(),
          weather_tracker_url: binary(),
          sensors: map(),
          measurements: map()
        }

  @spec start_link(map()) :: GenServer.on_start()
  def start_link(options \\ %{}) do
    Logger.info("Publisher started")
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  @impl true
  def init(options) do
    state = %{
      interval: Map.get(options, :interval, @default_publication_interval_milliseconds),
      weather_tracker_url: Map.get(options, :weather_tracker_url),
      sensors: Map.get(options, :sensors),
      measurements: :no_measurements
    }

    Logger.info("Publisher initialized with state #{inspect(state)}")

    schedule_next_publish(state.interval)

    {:ok, state}
  end

  @impl true
  def handle_info(:publish_data, state) do
    Logger.info("publish_data for state: #{inspect(state)}")
    new_state = measure(state)

    with :ok <- publish(new_state) do
      schedule_next_publish(state.interval)
      {:noreply, new_state}
    else
      error ->
        Logger.error("Unable to publish: #{inspect(error)}")
        {:noreply, state}
    end
  end

  @spec schedule_next_publish(integer()) :: reference()
  defp schedule_next_publish(interval) do
    Logger.info("scheduling next publish in #{interval} milliseconds")
    Process.send_after(self(), :publish_data, interval)
  end

  @spec measure(publisher_state()) :: publisher_state()
  defp measure(state) do
    measurements =
      Enum.reduce(state.sensors, %{}, fn sensor, acc ->
        sensor_reading = sensor.read.()
        sensor_data = sensor.convert.(sensor_reading)
        Map.merge(acc, sensor_data)
      end)

    Logger.info("measurements taken: #{inspect(measurements)}")

    %{state | measurements: measurements}
  end

  @spec publish(map()) :: :ok | {:error, Exception.t()}
  defp publish(state) do
    request = build_request(state)

    Logger.info("Making request #{inspect(request)}")

    case Finch.request(request, WeatherTrackerClient) do
      {:ok, response} ->
        Logger.debug("Server response: #{inspect(response)}")
        :ok

      error ->
        Logger.error("Error in Finch request: #{inspect(error)}")
        error
    end
  end

  @spec build_request(map()) :: Finch.Request.t()
  defp build_request(state) do
    Finch.build(
      :post,
      state.weather_tracker_url,
      @headers,
      Jason.encode!(state.measurements)
    )
  end
end
