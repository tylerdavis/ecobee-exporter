defmodule Ecobee.Api.Auth do
  require Logger

  use Tesla

  plug(Tesla.Middleware.BaseUrl, Ecobee.Api.endpoint())
  plug(Tesla.Middleware.Headers, Ecobee.Api.default_headers())
  plug(Tesla.Middleware.JSON)

  @spec request_pin() :: {:error, any()} | {:ok, Ecobee.Api.Models.PinResponse.t()}
  def request_pin do
    case get("/authorize",
           query: [
             response_type: "ecobeePin",
             scope: "smartWrite",
             client_id: Ecobee.Api.client_id()
           ]
         ) do
      {:ok, %Tesla.Env{body: %{"ecobeePin" => _} = body}} ->
        {:ok, Ecobee.Api.Models.PinResponse.init(body)}

      {:error, %Tesla.Env{body: body}} ->
        {:error, body}
    end
  end

  @spec get_tokens(binary()) :: {:error, any()} | {:ok, Ecobee.Api.Models.TokenResponse.t()}
  def get_tokens(code) do
    post("/token",
      %{},
      query: [
        grant_type: "ecobeePin",
        code: code,
        client_id: Ecobee.Api.client_id(),
        ecobee_type: "jwt"
      ]
    )
    |> handle_token_response()
  end

  @spec refresh_token(binary()) :: {:error, any()} | {:ok, Ecobee.Api.Models.TokenResponse.t()}
  def refresh_token(refresh_token) do
    post("/token",
      %{},
      query: [
        grant_type: "refresh_token",
        refresh_token: refresh_token,
        client_id: Ecobee.Api.client_id(),
        ecobee_type: "jwt"
      ]
    )
    |> handle_token_response()
  end

  defp handle_token_response({:ok, %Tesla.Env{body: %{"access_token" => _} = body}}) do
    token_response = Ecobee.Api.Models.TokenResponse.init(body)
    persist(token_response)
    {:ok, token_response}
  end

  defp handle_token_response({:ok, %Tesla.Env{status: 400} = env}) do
    Logger.debug("Token request failed: #{inspect(Jason.decode!(env.body))}")
    {:error, :unauthorized}
  end

  defp handle_token_response({:error, body}) do
    {:error, body}
  end

  defp persist(token) do
    Ecobee.Storage.put(:token, token)
  end
end
