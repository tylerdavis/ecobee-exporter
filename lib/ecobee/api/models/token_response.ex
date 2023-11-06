defmodule Ecobee.Api.Models.TokenResponse do
  use Ecobee.Api.Models.Base

  defstruct [:access_token, :token_type, :expires_in, :refresh_token, :scope]
end
