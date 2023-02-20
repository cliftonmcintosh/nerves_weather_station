defmodule VEML7700.Comm do
  @moduledoc """
  Module for communicating with the VEML7700 light sensor.
  """

  alias Circuits.I2C
  alias VEML7700.Config

  @light_register <<4>>

  @doc """
  Convenience function for discovering a VEML7700.
  """
  @spec discover(list(I2C.address())) :: {binary(), I2C.address()}
  def discover(possible_addresses \\ [0x10, 0x48]) do
    I2C.discover_one!(possible_addresses)
  end

  @doc """
  Convenience function for opening an I2C bus.
  """
  @spec open(binary()) :: {:ok, I2C.bus()} | {:error, term()}
  def open(bus_name) do
    with {:ok, i2c} <- I2C.open(bus_name) do
      i2c
    end
  end

  @doc """
  Writes configuration to the VEML7700 sensor.
  """
  @spec write_config(Config.t(), I2C.bus(), I2C.address()) :: :ok | {:error, term()}
  def write_config(config, i2c, sensor) do
    command = Config.to_integer(config)

    I2C.write(i2c, sensor, <<0, command::little-16>>)
  end

  @doc """

  """
  @spec read(I2C.bus(), I2C.address(), Config.t()) :: integer()
  def read(i2c, sensor, config) do
    <<value::little-16>> = I2C.write_read!(i2c, sensor, @light_register, 2)

    Config.to_lumens(config, value)
  end
end
