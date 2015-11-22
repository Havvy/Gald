defmodule GaldSite.PlayerOutToSocketHandler do
  @moduledoc """
  The player event emitter emits events in the form of
  {topic, payload}. This event handler orwards events
  to every listener of a channel with a topic of
  "player:topic".

  ## Topics

  * player:stats, stats
  """

  use GenEvent
  import ShortMaps

  # Callbacks
  @doc false
  def init(~m{socket}a) do
    {:ok, ~m{socket}a}
  end

  @doc false
  def handle_event({topic, payload}, ~m{socket}a) do
    payload = serialize_payload(topic, payload)
    topic = "private:#{Atom.to_string(topic)}"
    Phoenix.Channel.push(socket, topic, payload)
    {:ok, ~m{socket}a}
  end

  defp serialize_payload(:stats, stats), do: stats
  defp serialize_payload(topic, _payload), do: raise "Unknown event '#{inspect topic}'."
end
