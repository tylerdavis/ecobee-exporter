defmodule Ecobee.Api.Refresher do
  use GenServer
  require Logger

  alias Ecobee.Storage
  alias Ecobee.Api.Auth

  # 5 minutes
  @interval 5_000 * 60

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    Logger.debug "Refresher: Starting with interval: #{@interval / 1000} seconds"
    Process.send(self(), :work, [])
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    do_refresh()
    schedule_work()

    {:noreply, state}
  end

  defp do_refresh() do
    token_response = Storage.get(:token)
    if !is_nil(token_response) and token_response.refresh_token do
      Logger.debug("Refresher: Refreshing access token")
      case Auth.refresh_token(token_response.refresh_token) do
        {:error, reason} ->
          Logger.warning("Refresher: There was a problem refreshing the token: #{reason}")
        {:ok, _} ->
          Logger.debug("Refresher: Token updated")
      end
    else
      Logger.warning("Refresher: No refresh token found")
    end
  end

  defp schedule_work() do
    Process.send_after(self(), :work, @interval)
  end
end
