defmodule Ecobee.Api do
  def endpoint do
    "https://api.ecobee.com"
  end

  def default_headers do
    [{"content-type", "application/json"}]
  end

  def client_id do
    Application.get_env(:ecobee, :application_api_key)
  end
end
