defmodule GaldWeb.PlayerOutToSocketHandler do
  @moduledoc """
  The player event emitter emits events in the form of
  {topic, payload}. This event handler orwards events
  to every listener of a channel with a topic of
  "player:topic".

  ## Topics

  * player:stats, stats
  """

  use GenEvent
  import Destructure

  # Callbacks
  @doc false
  def init(d%{socket}) do
    {:ok, d%{socket}}
  end

  @doc false
  def handle_event({topic, payload}, d%{socket}) do
    payload = serialize_payload(topic, payload)
    topic = "private:#{Atom.to_string(topic)}"
    Phoenix.Channel.push(socket, topic, payload)
    {:ok, d%{socket}}
  end

  # TODO(Havvy): Rename to something else.
  defp serialize_payload(:stats, stats = d%{damage}) do
    damage = Enum.into(damage, %{})
    %{ stats | damage: damage }
  end
  defp serialize_payload(topic, _payload), do: raise "Unknown event '#{inspect topic}'."
end
