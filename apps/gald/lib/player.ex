# defmodule Gald.Player do
#   use Supervisor

#   # Client
#   @spec start_link(String.t) :: Supervisor.on_start
#   def start_link(name) do
#     Supervisor.start_link(__MODULE__, name)
#   end

#   # Server
#   def init(_name) do
#     children = []
#     supervise(children, strategy: :one_for_all)
#   end
# end

defmodule Gald.Player do
  use GenServer

  # Client
  def start_link(name) do
    GenServer.start_link(__MODULE__, name)
  end

  # Server
  def init(name) do
    {:ok, name}
  end
end

defmodule Gald.Player.Supervisor do
  use Supervisor

  # Client
  @spec start_link() :: Supervisor.on_start
  def start_link() do
    Supervisor.start_link(__MODULE__, [])
  end

  @spec add_player(pid, String.t) :: Supervisor.on_start
  def add_player(players, name) do
    Supervisor.start_child(players, [name])
  end

  # Server
  def init([]) do
    child = [supervisor(Gald.Player, [])]
    supervise(child, strategy: :simple_one_for_one)
  end
end