defmodule GaldSite.RaceOutToChannelHandler do
  @moduledoc """
  The race event emitter emits events in the form of
  {topic, payload}. This event handler orwards events
  to every listener of a channel with a topic of
  "global:topic".

  ## Topics

  * global:new_player, %{player_name: String}
  * global:begin, %{snapshot: %Gald.Snapshot{}}
  * global:finish, %{snapshot: %Gald.Snapshot{}}
  * global:round_start, %{round_number: number}
  * global:turn_start, %{player_name: String}
  * global:screen, %{name: String, data: Object}
  * global:move, %{to: number, entity_type: String, entity_name: string}
  """
  
  use GenEvent
  import ShortMaps

  # Callbacks
  @doc false
  def init(~m{channel}a) do
    channel = "race:#{channel}"
    {:ok, ~m{channel}a}
  end

  @doc false
  def handle_event({topic, payload}, ~m{channel}a) do
    payload = serialize_payload(topic, payload)
    # TODO(Havvy): Rename 'global' to 'public'.
    topic = "global:#{Atom.to_string(topic)}"
    GaldSite.Endpoint.broadcast!(channel, topic, payload)
    {:ok, ~m{channel}a}
  end

  # def handle_call(_msg, state) do
  #   {:ok, :ok, state}
  # end

  # def handle_info(_msg, state) do
  #   {:ok, state}
  # end

  defp serialize_payload(:new_player, player_name), do: ~m{player_name}a
  defp serialize_payload(:begin, snapshot), do: ~m{snapshot}a
  defp serialize_payload(:finish, snapshot), do: ~m{snapshot}a
  defp serialize_payload(:round_start, round_number), do: ~m{round_number}a
  defp serialize_payload(:turn_start, player_name), do: ~m{player_name}a
  defp serialize_payload(:screen, screen) do ~m{screen}a end
  defp serialize_payload(:move, %{to: to, who: {entity_type, entity_name}}) do
    ~m{entity_type entity_name to}a
  end
  defp serialize_payload(topic, _payload), do: raise "Unknown event '#{inspect topic}'."
end
