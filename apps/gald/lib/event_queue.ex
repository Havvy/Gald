# TODO(Havvy): This should only be loaded for tests.
defmodule EventQueue.Handler do
  require Logger
  use GenEvent

  def init(event_queue) do
    {:ok, event_queue}
  end

  def handle_event(event, event_queue) do
    Logger.info("EVENT: #{inspect event}")
    GenServer.cast(event_queue, {:event, event})
    {:ok, event_queue}
  end
end

defmodule EventQueue do
  @empty_queue :queue.new()

  use GenServer

  # Client
  def start_link(event_manager) do
    {:ok, self} = GenServer.start_link(__MODULE__, :no_args)
    GenEvent.add_handler(event_manager, EventQueue.Handler, self)
    {:ok, self}
  end

  def start(event_manager) do
    {:ok, self} = GenServer.start(__MODULE__, :no_args)
    GenEvent.add_handler(event_manager, EventQueue.Handler, self)
    {:ok, self}
  end

  def next(event_queue, timeout \\ 5000) do
    GenServer.call(event_queue, :next_eq, timeout)
  end

  def stop(event_queue) do
    GenServer.cast(event_queue, :stop)
  end

  # Server
  def init(:no_args) do
    {:ok, {@empty_queue, nil}}
  end

  def handle_cast({:event, event}, {queue, nil}) do
    {:noreply, {:queue.in(event, queue)}}
  end
  def handle_cast({:event, event}, {@empty_queue, from}) do
    GenServer.reply(from, event)
    {:noreply, {@empty_queue, nil}}
  end

  def handle_cast(:stop, _state) do
    {:stop, :normal, nil}
  end

  def handle_call(:next_eq, from, {@empty_queue, nil}) do
    {:noreply, {@empty_queue, from}}
  end
  def handle_call(:next_eq, _from, {queue, nil}) do
    {{:value, event}, queue} = :queue.out(queue)
    {:reply, event, queue}
  end

  def terminate(:normal, _state), do: :ok

  def terminate({:function_clause, _error}, _state), do: :ok
end