defmodule Ecobee.Api do
  def endpoint do
    "https://api.ecobee.com"
  end

  def default_headers do
    [{"content-type", "application/json"}]
  end

  def client_id do
    "2L670tccVbOHBRZrYmQNdcJss6z5xK5S"
  end
end
