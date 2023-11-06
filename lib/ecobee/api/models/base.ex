defmodule Ecobee.Api.Models.Base do

  @doc false
  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do

      def init(api_response_map) do
        atomized_keys_map = for {key, val} <- api_response_map, into: %{}, do: {String.to_atom(key), val}
        struct(__MODULE__, atomized_keys_map)
      end

    end
  end
end
