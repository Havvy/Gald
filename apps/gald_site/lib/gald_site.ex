defmodule GaldSite do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(GaldSite.Endpoint, []),
      worker(GaldSite.RaceManager, [[name: GaldSite.RaceManager]])
      # Start the Ecto repository
      # worker(GaldSite.Repo, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GaldSite.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    GaldSite.Endpoint.config_change(changed, removed)
    :ok
  end
end
