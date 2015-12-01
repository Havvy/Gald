defmodule Gald.Monsters do
  @moduledoc """
  A simple one for one supervisor for monsters.

  This will probably be changed when more thought is put into it.
  """
  
  use Supervisor
  import ShortMaps
  alias Gald.Monster

  # Client
  def start_link(init_map, otp_opts \\ []) do
    Supervisor.start_link(__MODULE__, init_map, otp_opts)
  end

  def start_monster(monsters, ~m{monster_module}a) do
    Supervisor.start_child(monsters, [~m{monster_module}a])
  end

  # Server
  def init(_arg) do
    children = [
      worker(Monster, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end