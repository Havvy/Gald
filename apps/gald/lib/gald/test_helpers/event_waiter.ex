# TODO(Havvy): This should only be loaded for tests.
defmodule Gald.TestHelpers.EventWaiter.Handler do
  use GenEvent
  require Logger

  def init(event_queue) do
    {:ok, event_queue}
  end

  def handle_event(event, event_queue) do
    Logger.info("EVENT: #{inspect event}")
    GenServer.cast(event_queue, {:event, event})
    {:ok, event_queue}
  end
end

defmodule Gald.TestHelpers.EventWaiter do
  @empty_queue :queue.new()

  use GenServer
  require Logger

  # Client
  def start_link(event_manager) do
    {:ok, self} = GenServer.start_link(__MODULE__, :no_args)
    GenEvent.add_handler(event_manager, Gald.TestHelpers.EventWaiter.Handler, self)
    {:ok, self}
  end

  def start(event_manager) do
    Logger.debug("Starting event waiter")
    {:ok, self} = GenServer.start(__MODULE__, :no_args)
    GenEvent.add_handler(event_manager, Gald.TestHelpers.EventWaiter.Handler, self)
    {:ok, self}
  end

  def await(event_queue, event, timeout \\ 5000) do
    GenServer.call(event_queue, {:await, event}, timeout)
  end

  def stop(event_queue) do
    GenServer.cast(event_queue, :stop)
  end

  # Server
  def init(:no_args) do
    {:ok, %{
      queue: @empty_queue,
      from: nil,
      awaiting: nil
    }}
  end

  def handle_cast({:event, event}, state = %{queue: queue, from: nil}) do
    {:noreply, %{ state | queue: :queue.in(event, queue) }}
  end
  def handle_cast({:event, {awaiting, _data}}, state = %{queue: @empty_queue, from: from, awaiting: awaiting}) do
    GenServer.reply(from, :ok)
    {:noreply, %{ state | queue: @empty_queue, from: nil, awaiting: nil }}
  end
  def handle_cast({:event, _event}, state) do
    {:noreply, state}
  end

  def handle_cast(:stop, _state) do
    {:stop, :normal, nil}
  end

  def handle_call({:await, awaiting}, from, state = %{queue: @empty_queue, from: nil}) do
    Logger.debug("Awaiting event '#{awaiting}'.")
    {:noreply, %{ state | from: from, awaiting: awaiting }}
  end
  def handle_call({:await, awaiting}, from, state = %{queue: queue}) do
    Logger.debug("Awaiting event '#{awaiting}'.")
    {queue, awaited} = take_until(queue, awaiting)

    if (awaited != nil) do
      {:reply, awaited, %{ state | queue: queue, from: nil, awaited: nil }}
    else
      {:noreply, %{ state | queue: queue, from: from, awaiting: awaiting }}
    end
  end

  defp take_until(@empty_queue, _until) do
    {@empty_queue, nil}
  end
  defp take_until(queue, until) do
    {{:value, {event, data}}, queue} = :queue.out(queue)

    if (event == until) do
      {queue, data}
    else
      take_until(queue, until)
    end
  end
end