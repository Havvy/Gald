defmodule GaldWeb.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(GaldWeb.Endpoint, []),
      worker(GaldWeb.RaceManager, [[name: GaldWeb.RaceManager]])
      # Start the Ecto repository
      # worker(GaldWeb.Repo, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GaldWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    GaldWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
