defmodule GaldSite.Room.Supervisor do
  use Supervisor

  ## Client
  def start_link() do
    Supervisor.start_link(__MODULE__, :ok)
  end

  ## Server
  def init(:ok) do
    children = [
      worker(GaldSite.Room, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end