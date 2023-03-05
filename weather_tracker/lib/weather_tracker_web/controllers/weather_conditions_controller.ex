defmodule WeatherTrackerWeb.WeatherConditionsController do
  @moduledoc """
  Controller for weather conditions API.
  """
  use WeatherTrackerWeb, :controller

  require Logger

  alias WeatherTracker.WeatherConditions
  alias WeatherTracker.WeatherConditions.WeatherCondition

  def create(conn, params) do
    IO.inspect(params)

    case WeatherConditions.create_entry(params) do
      {:ok, %WeatherCondition{} = weather_condition} ->
        Logger.debug("Successfully created a weather condition entry")

        conn
        |> put_status(:created)
        |> json(weather_condition)

      error ->
        Logger.warn("Failed to create a weather condition entry: #{inspect(error)}")

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{message: "Poorly formatted payload"})
    end
  end
end
