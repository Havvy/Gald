defmodule Gald.Player.Supervisor do
  use Supervisor

  # Client
  def start_link() do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def add_player(supervisor) do
    Supervisor.start_child(supervisor, [])
  end

  # Server
  def init(:ok) do
    child = [supervisor(Gald.Player, [])]
    supervise(child, strategy: :simple_one_for_one)
  end
end