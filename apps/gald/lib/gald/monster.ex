defmodule Gald.Monster do
  @moduledoc false
  
  use GenServer
  alias Gald.MonsterStats
  alias Gald.MonsterAttack

  # Behaviour
  @type state :: Map.t
  @callback init(Map.t) :: %{stats: %MonsterStats{}, state: state}
  @callback attack(Map.t) :: %{attack: %MonsterAttack{}, stats: %MonsterStats{}, state: state}

  defmacro __using__(_opts) do
    quote do
      @behaviour Gald.Monster
      alias Gald.MonsterStats
      alias Gald.MonsterAttack
    end
  end

  # Server
  def start_link(init_arg, otp_opts) do
    GenServer.start_link(__MODULE__, init_arg, otp_opts)
  end

  # Client
  def init(%{module: module}) do
    %{stats: stats, state: state} = apply(module, :init, %{})

    {:ok, %{
      module: module,
      stats: stats,
      state: state
    }}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end