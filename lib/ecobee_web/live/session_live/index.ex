defmodule EcobeeWeb.SessionLive.Index do
  @moduledoc """
  Authenticates the exporter with your Ecobee account.

  1. Requests a pin from Ecobee.
  2. Waits for the user to enter the pin on the Ecobee website.
  3. When user enters the pin, we request a token from Ecobee and store it locally.

  ## States

  * `:ready` - The initial state. Ready to request a pin from Ecobee.
  * `:requesting_pin` - Waits for the user to enter the pin on the Ecobee website.
  * `:displaying_pin` - The pin has been received from Ecobee and is displayed to the user.
  * `:requesting_token` - When user enters the pin, we request a token from Ecobee.
  * `:authenticated` - We have received the token from Ecobee.  The exporter is now authenticated.
  * `:error` - Error state.  Something went wrong, you need to check your configuration and start over.
  """
  use EcobeeWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    case Ecobee.Storage.get(:token) do
      nil ->
        {
          :ok,
          socket
          |> assign(:state, :ready)
          |> assign(:pin_response, nil)
          |> assign(:token_response, nil)
        }
      token ->
        {
          :ok,
          socket
          |> assign(:state, :authenticated)
          |> assign(:pin_response, nil)
          |> assign(:token_response, token)
        }
    end
  end

  @impl true
  def handle_event("request-pin", _, socket) do
    send(self(), :request_pin)
    {
      :noreply,
      socket
      |> assign(:state, :requesting_pin)
    }
  end

  @impl true
  def handle_event("finish-authentication", _, socket) do
    send(self(), :request_token)
    {
      :noreply,
      socket
      |> assign(:state, :requesting_token)
    }
  end

  def handle_event("reset-session", _, socket) do
    {
      :noreply,
      socket
      |> assign(:state, :ready)
    }
  end

  @impl true
  def handle_info(:request_pin, socket) do
    case Ecobee.Api.Auth.request_pin() do
      {:ok, pin} ->
        {
          :noreply,
          socket
          |> assign(:state, :displaying_pin)
          |> assign(:pin_response, pin)
        }
      {:error, body} ->
        dbg(body)
        {
          :noreply,
          socket
          |> assign(:state, :error)
        }
    end
  end

  @impl true
  def handle_info(:request_token, socket) do
    case Ecobee.Api.Auth.get_tokens(socket.assigns.pin_response.code) do
      {:ok, token} ->
        {
          :noreply,
          socket
          |> assign(:state, :authenticated)
          |> assign(:token_response, token)
        }
      {:error, body} ->
        dbg(body)
        {
          :noreply,
          socket
          |> assign(:state, :error)
        }
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container">
      <div class="row">
        <div class="col">
          <h1>Ecobee Prometheus Exporter</h1>
          <p>Authenticate with Ecobee to start exporting metrics.</p>

          <div :if={@state == :ready}>
            <button phx-click="request-pin">Request Ecobee PIN</button>
          </div>

          <div :if={@state == :requesting_pin}>
            <p>Requesting PIN...</p>
          </div>

          <div :if={@state == :displaying_pin}>
            <h2>Ecobee PIN: <input value={@pin_response.ecobeePin} /></h2>

            <p>Once you've entered the pin into the Ecobee site, click the button to finish authentication.</p>

            <button phx-click="finish-authentication">Finish Authentication</button>
          </div>

          <div :if={@state == :requesting_token}>
            <p>Requesting token...</p>
          </div>

          <div :if={@state == :authenticated}>
            <p>You're all set!  You can check your metrics at <code><a href="/metrics">/metrics</a></code></p>
          </div>

          <div style="margin-top:4rem;display:none">
            <hr/>
            <h2>DEBUG</h2>
            <p>State: <%= @state |> Atom.to_string() %></p>
            <pre :if={@pin_response}>
              <code><%= %{ code: @pin_response.code, pin: @pin_response.ecobeePin, expires_in: @pin_response.expires_in, interval: @pin_response.expires_in, scope: @pin_response.scope } |> Jason.encode!() %></code>
            </pre>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
