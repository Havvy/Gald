defmodule Gald.Player do
  use Supervisor

  # Client
  def start_link() do
    Supervisor.start_link(__MODULE__, :ok)
  end

  # Server
  def init(:ok) do
    children = []
    supervise(children, strategy: :one_for_all)
  end
end
