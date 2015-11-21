defmodule Gald.EventManager do
  """
  Manages events.
  """

  use GenServer

  # Client
  def start_link(init_arg, otp_opts \\ []) do
    GenServer.start_link(__MODULE__, init_arg, otp_opts)
  end

  def next(event_manager) do
    GenServer.call(event_manager, :next)
  end

  # Server
  def init(%{}) do
    {:ok, %{}}
  end

  def handle_call(:next, _from, state) do
    {:reply, {Gald.Screen.NonEvent, nil}, state}
  end
  
end