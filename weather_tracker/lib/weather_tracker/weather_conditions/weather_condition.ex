defmodule WeatherTracker.WeatherConditions.WeatherCondition do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields ~w(
    altitude_m
    co2_eq_ppm
    light_lumens
    pressure_pa
    temperature_c
    tvoc_ppb
  )a

  @optional_fields ~w()a

  @derive {Jason.Encoder, only: @required_fields}
  @primary_key false
  schema "weather_conditions" do
    field :altitude_m, :decimal
    field :co2_eq_ppm, :decimal
    field :light_lumens, :decimal
    field :pressure_pa, :decimal
    field :temperature_c, :decimal
    field :timestamp, :naive_datetime
    field :tvoc_ppb, :decimal
  end

  @doc """
  Creates a changeset for creating a WeatherCondition.
  """
  def create_changeset(weather_condition \\ %__MODULE__{}, attrs) do
    now = NaiveDateTime.utc_now()
    timestamp = NaiveDateTime.truncate(now, :second)

    weather_condition
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> put_change(:timestamp, timestamp)
  end
end
