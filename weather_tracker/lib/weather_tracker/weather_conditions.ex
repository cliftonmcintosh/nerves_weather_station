defmodule WeatherTracker.WeatherConditions do
  @moduledoc """
  Context module for weather conditions.
  """
  alias WeatherTracker.Repo
  alias WeatherTracker.WeatherConditions.WeatherCondition

  @spec create_entry(map()) :: {:ok, WeatherCondition.t()} | {:error, Ecto.Changeset.t()}
  def create_entry(attrs) do
    attrs
    |> WeatherCondition.create_changeset()
    |> Repo.insert()
  end
end
