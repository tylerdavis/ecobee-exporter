defmodule Ecobee.PromExPlugin do
  @moduledoc """
  This module defines the metrics that will be collected by the exporter.

  Available metrics
  -----------------

  ecobee_sensor_temperature_fahrenheit
  ecobee_sensor_humidity_ratio
  ecobee_thermostat_desired_cool_fahrenheit
  ecobee_thermostat_desired_heat_fahrenheit
  ecobee_thermostat_desired_humidity_ratio

  """
  use PromEx.Plugin

  @metric_prefix [:ecobee]

  @thermostat_event [:prom_ex, :plugin, :ecobee, :thermostat]

  @temperature_event [:prom_ex, :plugin, :ecobee, :sensor, :temperature]
  @humidity_event [:prom_ex, :plugin, :ecobee, :sensor, :humidity]

  @desired_temperature_event [:prom_ex, :plugin, :ecobee, :thermostat, :desired_temperature]
  @desired_humidity_event [:prom_ex, :plugin, :ecobee, :thermostat, :desired_humidity]

  @impl true
  def polling_metrics(opts) do
    poll_rate = Keyword.get(opts, :poll_rate, 5_000)

    [
      ecobee_metrics(poll_rate)
    ]
  end

  def ecobee_metrics(poll_rate) do
    Polling.build(
      :ecobee_sensor_data,
      poll_rate,
      {__MODULE__, :execute_thermostat_query, []},
      [
        last_value(
          @metric_prefix ++ [:sensor, :temperature, :fahrenheit],
          event_name: @temperature_event,
          description: "A remote sensor temperature reading",
          tags: [:name, :thermostat_name, :thermostat_id],
          measurement: :value,
          unit: :fahrenheit
        ),
        last_value(
          @metric_prefix ++ [:sensor, :humidity, :ratio],
          event_name: @humidity_event,
          description: "A remote sensor humidity reading",
          tags: [:name, :thermostat_name, :thermostat_id],
          measurement: :value,
          unit: :ratio
        ),
        last_value(
          @metric_prefix ++ [:thermostat, :desired, :temperature, :fahrenheit],
          event_name: @desired_temperature_event,
          description: "A desired temperature reading",
          tags: [:type, :thermostat_name, :thermostat_id],
          measurement: :value,
          unit: :fahrenheit
        ),
        last_value(
          @metric_prefix ++ [:thermostat, :desired, :humidity, :ratio],
          event_name: @desired_humidity_event,
          description: "A desired humidity reading",
          tags: [:type, :thermostat_name, :thermostat_id],
          measurement: :value,
          unit: :ratio
        )
      ]
    )
  end

  @doc false
  def execute_thermostat_query do
    token = Ecobee.Storage.get(:token).access_token
    client = Ecobee.Api.Client.new(token)

    case Ecobee.Api.Client.thermostat(client) do
      {:ok, response} ->
        Enum.each(response["thermostatList"], fn thermostat ->

          thermostat_name = thermostat["name"]
          thermostat_id = thermostat["identifier"]

          thermostat["remoteSensors"]
          |> Enum.map(fn sensor ->
            name = sensor["name"]
            record_temperature_capability(
              sensor,
              %{name: name, thermostat_name: thermostat_name, thermostat_id: thermostat_id}
            )
            record_humidity_capability(
              sensor,
              %{name: name, thermostat_name: thermostat_name, thermostat_id: thermostat_id}
            )
          end)

          record_runtime_temperature_value(
            thermostat["runtime"],
            @desired_temperature_event,
            "desiredCool",
            %{type: "cool", thermostat_name: thermostat_name, thermostat_id: thermostat_id}
          )
          record_runtime_temperature_value(
            thermostat["runtime"],
            @desired_temperature_event,
            "desiredHeat",
            %{type: "heat", thermostat_name: thermostat_name, thermostat_id: thermostat_id}
          )
          record_runtime_humidity_value(
            thermostat["runtime"],
            @desired_humidity_event,
            "desiredHumidity",
            %{type: "humidity", thermostat_name: thermostat_name, thermostat_id: thermostat_id}
          )
        end)
      {:error, err} ->
        IO.inspect(err)
    end
  end

  defp record_runtime_temperature_value(map, event, key, tags) do
    if value = temp_value(map[key]) do
      :telemetry.execute(event, %{value: value}, tags)
    end
  end

  defp record_runtime_humidity_value(map, event, key, tags) do
    if value = humidity_value(map[key]) do
      :telemetry.execute(event, %{value: value}, tags)
    end
  end

  defp record_temperature_capability(sensor, tags) do
    temperature = sensor["capability"] |> Enum.find(fn capability -> capability["type"] == "temperature" end)
    if value = temp_value(temperature["value"]) do
      :telemetry.execute(@temperature_event, %{value: value}, tags)
    end
  end

  defp record_humidity_capability(sensor, tags) do
    humidity = sensor["capability"] |> Enum.find(fn capability -> capability["type"] == "humidity" end)
    if value = humidity_value(humidity["value"]) do
      :telemetry.execute(@humidity_event, %{value: value}, tags)
    end
  end

  defp temp_value(value) when is_binary(value) do
    value = value
    |> String.to_integer()
    value / 10.0
  end

  defp temp_value(value) when is_number(value) do
    value / 10.0
  end

  defp temp_value(value) when is_nil(value) do
    nil
  end

  defp humidity_value(value) when is_binary(value) do
    value = value
    |> String.to_integer()
    value / 100.0
  end

  defp humidity_value(value) when is_number(value) do
    value / 100.0
  end

  defp humidity_value(value) when is_nil(value) do
    nil
  end
end
