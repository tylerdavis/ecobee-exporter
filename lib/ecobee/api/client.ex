defmodule Ecobee.Api.Client do
  use Tesla

  def new(token) do
    Tesla.client [
      {Tesla.Middleware.BearerAuth, token: token},
      {Tesla.Middleware.BaseUrl, Ecobee.Api.endpoint()},
      {Tesla.Middleware.Headers, Ecobee.Api.default_headers()},
      # {Tesla.Middleware.JSON}
    ]
  end

  def thermostat(client) do
    case Tesla.get(client, "/1/thermostat", query: [json: json()]) do
      {:ok, env} ->
        {:ok, env.body |> Jason.decode!()}
      {:error, err} ->
        {:error, err}
    end
  end

  defp json do
    %{
      selection: %{
        selectionType: "registered",
        selectionMatch: "",
        includeRuntime: "true",
        includeExtendedRuntime: "true",
        includeSensors: "true",
      }
    } |> Jason.encode!()
  end
end
