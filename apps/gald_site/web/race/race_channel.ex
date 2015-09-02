defmodule GaldSite.RaceChannel do
  use Phoenix.Channel

  # TODO(Havvy): CODE(MULTIPLAYER): Remove me.
  def join("race:lobby", _auth_msg, socket) do
    race = get_race
    snapshot = Gald.Race.snapshot(race)
    {:ok, snapshot, socket}
  end

  # TODO(Havvy): CODE(MULTIPLAYER): Write me.
  def join("race:" <> _private_room_id, _auth_msg, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  # TODO(Havvy): Remove me at some point. This should *never* be possible.
  def join(_chan, _auth_msg, _socket) do
    {:error, %{reason: "unknown-channel"}}
  end

  # TODO(Havvy): Figure out how to store the player as something the player can authenticate as.
  # TODO(Havvy): Get a player name from the player.
  def handle_in("join", %{"name" => name}, socket) do
    race = get_race
    case Gald.Race.add_player(race, name) do
      :ok ->
        broadcast! socket, "g-join", %{name: name}
        {:reply, {:ok, %{name: name}}, socket}
      {:error, :duplicate_name} ->
        {:reply, {:error, %{reason: "Cannot join game with that name. Name is already taken."}}, socket}
      {:error, :already_started} ->
        {:reply, {:error, %{reason: "Cannot join game. Game is already started."}}, socket}
    end
  end

  def handle_in("start", %{}, socket) do
    race = get_race()
    # TODO(Havvy): Check if game is already started.
    # TODO(Havvy): Check if player has ability to start game.
    Gald.Race.start_game(race)
    broadcast! socket, "g-start", %{snapshot: Gald.Race.snapshot(race)}
    {:reply, {:ok, %{}}, socket}
  end

  def handle_in("move", %{"player" => player}, socket) do
    # TODO(Havvy): Check if it is the player's turn (in Gald itself though).
    # TODO(Havvy): All of this logic in the Gald app itself.
    race = get_race

    if Gald.Race.is_over(race) do
      {:reply, {:error, %{reason: "Cannot move. Game is over."}}, socket}
    else
      Gald.Race.move_player(race, player, 10)
      broadcast! socket, "g-move_player", %{player: player, spaces: 10, end_space: Gald.Race.get_player_location(race, player)}

      if Gald.Race.is_over(race) do
        broadcast! socket, "g-game_over", %{snapshot: Gald.Race.snapshot(race)}
      end

      {:reply, {:ok, %{}}, socket}
    end
  end

  # TODO(Havvy): CODE(MULTIROOM): Remove me.
  def handle_in("temp-start-new-game", %{}, socket) do
    GaldSite.RaceManager.new_race("lobby", 60)
    broadcast! socket, "g-temp-new-game", %{}
    {:noreply, socket}
  end

  defp get_race, do: GaldSite.RaceManager.get("lobby")
end