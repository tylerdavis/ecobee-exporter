defmodule Ecobee.Api.Models.PinResponse do
  use Ecobee.Api.Models.Base

  defstruct [:code, :ecobeePin, :expires_in, :interval, :scope]
end
