defmodule Ecobee.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      EcobeeWeb.Telemetry,
      {Phoenix.PubSub, name: Ecobee.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Ecobee.Finch},
      # Start a worker by calling: Ecobee.Worker.start_link(arg)
      # {Ecobee.Worker, arg},
      # Start to serve requests, typically the last entry
      EcobeeWeb.Endpoint,
      {CubDB, data_dir: "priv/data", name: Ecobee.CubDB},
      Ecobee.PromEx,
      Ecobee.Api.Refresher,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ecobee.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EcobeeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
