defmodule VEML7700 do
  @moduledoc """
  GenServer for the VEML7700 light sensor.
  """
  use GenServer

  require Logger

  alias VEML7700.Comm
  alias VEML7700.Config

  @impl true
  def init(%{address: address, i2c_bus_name: bus_name} = args) do
    i2c = Comm.open(bus_name)

    config =
      args
      |> Map.take([:gain, :int_time, :shutdown, :interrupt])
      |> Config.new()

    Comm.write_config(config, i2c, address)
    :timer.send_interval(1_000, :measure)

    state = %{
      i2c: i2c,
      address: address,
      config: config,
      last_reading: :no_reading
    }

    {:ok, state}
  end

  def init(args) do
    {bus_name, address} = Comm.discover()
    transport = "bus: #{bus_name}, address: #{address}"

    Logger.info("Starting VEML7700. Please specify an address and a bus.")
    Logger.info("Starting on " <> transport)

    args
    |> Map.merge(%{address: address, i2c_bus_name: bus_name})
    |> init()
  end

  @impl true
  def handle_info(:measure, %{i2c: i2c, address: address, config: config} = state) do
    reading = Comm.read(i2c, address, config)

    updated_with_reading = %{state | last_reading: reading}
    {:noreply, updated_with_reading}
  end

  @impl true
  def handle_call(:get_measurement, _from, state) do
    {:reply, state.last_reading, state}
  end

  @spec start_link(map()) :: GenServer.on_start()
  def start_link(options \\ %{}) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  @spec get_measurement :: integer()
  def get_measurement do
    GenServer.call(__MODULE__, :get_measurement)
  end
end
