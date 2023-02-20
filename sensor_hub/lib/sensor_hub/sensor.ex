defmodule SensorHub.Sensor do
  @moduledoc """
  A module for normalizing sensor measurements.
  """

  @type t :: %__MODULE__{}
  @type environment_reading :: %{
          altitude_m: float(),
          pressure_pa: float(),
          temperature_c: float()
        }
  @type gas_reading :: %{co2_eq_ppm: float(), tvoc_ppb: float()}
  @type light_reading :: %{light_lumens: float()}
  @type reading :: environment_reading() | gas_reading() | light_reading()

  defstruct [:convert, :fields, :name, :read]

  @doc """
  Constructor for new Sensor struct.
  """
  @spec new(module()) :: t()
  def new(name) do
    %__MODULE__{
      convert: convert(name),
      fields: fields(name),
      name: name,
      read: read(name)
    }
  end

  @doc """
  Returns the reading from a sensor.
  """
  @spec measure(module()) :: reading()
  def measure(sensor) do
    sensor.convert.(sensor.read.())
  end

  @spec fields(module()) :: list(atom())
  defp fields(SGP30), do: [:co2_eq_ppm, :tvoc_ppb]
  defp fields(BMP280), do: [:altitude_m, :pressure_pa, :temperature_c]
  defp fields(VEML7700), do: [:light_lumens]

  @spec read(term()) :: function()
  defp read(SGP30), do: fn -> SGP30.state() end
  defp read(BMP280), do: fn -> BMP280.measure(BMP280) end
  defp read(VEML7700), do: fn -> VEML7700.get_measurement() end

  @spec convert(module()) :: function()
  defp convert(SGP30) do
    fn reading ->
      Map.take(reading, [:co2_eq_ppm, :tvoc_ppb])
    end
  end

  defp convert(BMP280) do
    fn reading ->
      case reading do
        {:ok, measurement} ->
          Map.take(measurement, [:altitude_m, :pressure_pa, :temperature_c])

        _ ->
          %{}
      end
    end
  end

  defp convert(VEML7700) do
    fn data -> %{light_lumens: data} end
  end
end
