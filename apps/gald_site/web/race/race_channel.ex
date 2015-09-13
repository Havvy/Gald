defmodule GaldSite.RaceChannel do
  use Phoenix.Channel
  defp get_race(socket), do: socket.assigns.race

  def join("race:" <> name, _auth_msg, socket) do
    case GaldSite.RaceManager.get(name) do
      {:ok, race} ->
        socket = Phoenix.Socket.assign(socket, :race, race)
        {:ok, Gald.Race.snapshot(race), socket}
      {:error, reason} -> {:error, %{reason: reason}}
    end
  end

  # TODO(Havvy): Remove me at some point. This should *never* be possible.
  def join(_chan, _auth_msg, _socket) do
    {:error, %{reason: "unknown-channel"}}
  end

  # TODO(Havvy): Figure out how to store the player as something the player can authenticate as.
  # TODO(Havvy): Get a player name from the player.
  def handle_in("join", %{"name" => name}, socket) do
    race = get_race(socket)
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
    race = get_race(socket)
    # TODO(Havvy): Check if game is already started.
    # TODO(Havvy): Check if player has ability to start game.
    Gald.Race.start_game(race)
    broadcast! socket, "g-start", %{snapshot: Gald.Race.snapshot(race)}
    {:reply, {:ok, %{}}, socket}
  end

  def handle_in("move", %{"player" => player}, socket) do
    # TODO(Havvy): Check if it is the player's turn (in Gald itself though).
    # TODO(Havvy): All of this logic in the Gald app itself.
    race = get_race(socket)

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
end