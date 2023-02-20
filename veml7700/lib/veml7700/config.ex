defmodule VEML7700.Config do
  @moduledoc """
  Configuration for the VEML7700 light sensor.
  """

  @type t :: %__MODULE__{}
  @type gain :: :gain_2x | :gain_1x | :gain_1_4th | :gain_1_8th | :gain_default
  @type int_time ::
          :it_25_ms | :it_50_ms | :it_100_ms | :it_200_ms | :it_400_ms | :it_800_ms | :it_default

  @to_lumens_factor %{
    {:it_800_ms, :gain_2x} => 0.0036,
    {:it_800_ms, :gain_1x} => 0.0072,
    {:it_800_ms, :gain_1_4th} => 0.0288,
    {:it_800_ms, :gain_1_8th} => 0.0576,
    {:it_400_ms, :gain_2x} => 0.0072,
    {:it_400_ms, :gain_1x} => 0.0144,
    {:it_400_ms, :gain_1_4th} => 0.0576,
    {:it_400_ms, :gain_1_8th} => 0.1152,
    {:it_200_ms, :gain_2x} => 0.0144,
    {:it_200_ms, :gain_1x} => 0.0288,
    {:it_200_ms, :gain_1_4th} => 0.1152,
    {:it_200_ms, :gain_1_8th} => 0.2304,
    {:it_100_ms, :gain_2x} => 0.0288,
    {:it_100_ms, :gain_1x} => 0.0576,
    {:it_100_ms, :gain_1_4th} => 0.2304,
    {:it_100_ms, :gain_1_8th} => 0.4608,
    {:it_50_ms, :gain_2x} => 0.0576,
    {:it_50_ms, :gain_1x} => 0.1152,
    {:it_50_ms, :gain_1_4th} => 0.4608,
    {:it_50_ms, :gain_1_8th} => 0.9216,
    {:it_25_ms, :gain_2x} => 0.1152,
    {:it_25_ms, :gain_1x} => 0.2304,
    {:it_25_ms, :gain_1_4th} => 0.9216,
    {:it_25_ms, :gain_1_8th} => 1.8432
  }

  @doc """
  The struct for the VEML7700's configuration.
  """
  defstruct gain: :gain_1_4th, int_time: :it_100_ms, shutdown: false, interrupt: false

  @doc """
  Returns a new configuration struct.
  """
  @spec new :: t()
  def new, do: struct(__MODULE__)

  @doc """
  Returns a new configuration struct with options for setting the configuration.
  """
  @spec new(Keyword.t()) :: t()
  def new(opts), do: struct(__MODULE__, opts)

  @doc """
  Function to convert configuration to an integer.
  """
  @spec to_integer(t()) :: integer()
  def to_integer(config) do
    reserved = 0
    persistence_protect = 0

    <<integer::16>> = <<
      reserved::3,
      gain(config.gain)::2,
      reserved::1,
      int_time(config.int_time)::4,
      persistence_protect::2,
      reserved::2,
      interrupt(config.interrupt)::1,
      shutdown(config.shutdown)::1
    >>

    integer
  end

  @doc """
  Converts light measurement to lumens.
  """
  @spec to_lumens(t(), number()) :: float()
  def to_lumens(%__MODULE__{int_time: int_time, gain: gain}, measurement) do
    @to_lumens_factor[{int_time, gain}] * measurement
  end

  @spec gain(gain()) :: integer()
  defp gain(:gain_1x), do: 0b0
  defp gain(:gain_2x), do: 0b01
  defp gain(:gain_1_8th), do: 0b10
  defp gain(:gain_1_4th), do: 0b11
  defp gain(:gain_default), do: gain(:gain_1_4th)

  @spec int_time(int_time()) :: integer()
  defp int_time(:it_25_ms), do: 0b1100
  defp int_time(:it_50_ms), do: 0b1000
  defp int_time(:it_100_ms), do: 0b0000
  defp int_time(:it_200_ms), do: 0b0001
  defp int_time(:it_400_ms), do: 0b0010
  defp int_time(:it_800_ms), do: 0b0011
  defp int_time(:it_default), do: int_time(:it_800_ms)

  @spec shutdown(boolean()) :: 0 | 1
  defp shutdown(true), do: 1
  defp shutdown(_), do: 0

  @spec interrupt(boolean()) :: 0 | 1
  defp interrupt(true), do: 1
  defp interrupt(_), do: 0
end
