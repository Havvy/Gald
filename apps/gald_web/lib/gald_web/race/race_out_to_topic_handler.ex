defmodule GaldWeb.RaceOutToTopicHandler do
  @moduledoc """
  The race event emitter emits events in the form of {event, payload}.
  This event handler forwards events to every listener of a channel with an
  event name of "public:{event}"

  The only other event that is sent outside of this GenEvent is `public:crash`
  for when a race crashes. And it is the RaceManager that handles that. It has
  no payload.

  ## Events

  * public:new_player, %{player_name: String}
  * public:begin, %{snapshot: %Gald.Snapshot{}}
  * public:finish, %{snapshot: %Gald.Snapshot{}}
  * public:round_start, %{round_number: number}
  * public:turn_start, %{player_name: String}
  * public:screen, %{name: String, data: Object}
  * public:move, %{to: number, entity_type: String, entity_name: string}
  """
  
  use GenEvent
  import ShortMaps
  require Logger

  # Callbacks
  @doc false
  def init(~m{topic}a) do
    topic = "race:#{topic}"
    {:ok, ~m{topic}a}
  end

  @doc false
  def handle_event({event, payload}, ~m{topic}a) do
    payload = serialize_payload(event, payload)
    event = "public:#{Atom.to_string(event)}"
    GaldWeb.Endpoint.broadcast!(topic, event, payload)
    {:ok, ~m{topic}a}
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
  defp serialize_payload(:move, %{to: to, who: {entity_type, entity_name}}) do
    ~m{entity_type entity_name to}a
  end
  defp serialize_payload(:screen, screen) do
    style = screen.__struct__ |> Module.split() |> List.last()
    ~m{screen style}a
  end
  defp serialize_payload(:death, player_name), do: ~m{player_name}a
  defp serialize_payload(:respawn, player_name), do: ~m{player_name}a
  defp serialize_payload(topic, _payload), do: raise "Unknown event '#{inspect topic}'."
end
