# TODO(Havvy): This should only be loaded for tests.
defmodule Gald.TestHelpers.EventQueue.Handler do
  require Logger
  use GenEvent
  import ShortMaps

  def init(~m{event_queue name}a) do
    {:ok, ~m{event_queue name}a}
  end

  def handle_event(event, ~m{event_queue name}a) do
    Logger.info("EVENT[#{name}]: #{inspect event}")
    GenServer.cast(event_queue, {:event, event})
    {:ok, ~m{event_queue name}a}
  end
end

defmodule Gald.TestHelpers.EventQueue do
  @empty_queue :queue.new()

  use GenServer
  require Logger

  # Client
  def start_link(event_manager, name) do
    {:ok, self} = GenServer.start_link(__MODULE__, :no_args)
    GenEvent.add_handler(event_manager, Gald.TestHelpers.EventQueue.Handler, %{
      event_queue: self,
      name: name
    })
    {:ok, self}
  end

  def start(event_manager, name) do
    {:ok, self} = GenServer.start(__MODULE__, name)
    GenEvent.add_handler(event_manager, Gald.TestHelpers.EventQueue.Handler, %{
      event_queue: self,
      name: name
    })
    {:ok, self}
  end

  def next(event_queue, timeout \\ 5000) do
    GenServer.call(event_queue, :next, timeout)
  end

  def stop(event_queue) do
    GenServer.cast(event_queue, :stop)
  end

  # Server
  def init(name) do
    {:ok, %{queue: @empty_queue, from: nil, name: name}}
  end

  def handle_cast({:event, event}, state = %{queue: queue, from: nil}) do
    queue = :queue.in(event, queue)
    {:noreply, %{ state | queue: queue }}
  end
  def handle_cast({:event, event}, state = %{queue: @empty_queue, from: from}) do
    GenServer.reply(from, event)
    {:noreply, %{ state | queue: @empty_queue, from: nil }}
  end

  def handle_cast(:stop, _state) do
    {:stop, :normal, nil}
  end

  def handle_call(:next, from, state = %{queue: @empty_queue, from: nil}) do
    {:noreply, %{ state | from: from }}
  end
  def handle_call(:next, _from, %{queue: queue, from: nil }) do
    {{:value, event}, queue} = :queue.out(queue)
    {:reply, event, queue}
  end

  def terminate(:normal, _state), do: :ok

  def terminate({:function_clause, _error}, _state), do: :ok
end