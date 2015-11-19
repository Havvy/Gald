defmodule GaldSite.RaceChannel do
  use Phoenix.Channel
  require Logger
  import ShortMaps
  alias GaldSite.RaceManager

  defp get_race(socket), do: socket.assigns.race
  defp get_internal_name(socket), do: socket.assigns.internal_name

  def join("race:" <> internal_name, _auth_msg, socket) do
    # TODO(Havvy): Send the channel PID instead of the transport_pid?
    case RaceManager.put_viewer(internal_name, socket.transport_pid) do
      :ok ->
        {:ok, race} = RaceManager.get(internal_name)
        socket = Phoenix.Socket.assign(socket, :race, race)
        socket = Phoenix.Socket.assign(socket, :internal_name, internal_name)
        Logger.debug("Race channel connected.")
        {:ok, Gald.Race.snapshot(race), socket}
      {:error, reason} -> {:error, %{reason: reason}}
    end
  end
  def join(_chan, _auth_msg, _socket) do
    {:error, %{reason: "unknown-channel"}}
  end

  @doctype """
  One of "join", "start", or "option".
  """
  @type in_type :: String.t

  @spec handle_in(in_type, Map.t, Phoenix.Socket.t) :: {:reply, Phoenix.Channel.reply, Phoenix.Socket.t}

  def handle_in("join", %{"name" => player_name}, socket) do
    if Regex.match?(~R/[^\p{L}0-9-]/, player_name) do
      {:reply, {:error, %{reason: "Invalid nickname. Only letters, numbers, and dashes are allowed."}}, socket}
    else
      race = get_race(socket)
      case Gald.Race.new_player(race, player_name) do
        {:ok, {input, output}} ->
          socket = Phoenix.Socket.assign(socket, :player_input, input)
          # TODO(Havvy): Don't assign to socket; attach listener instead.
          socket = Phoenix.Socket.assign(socket, :player_output, output)
          {:reply, {:ok, %{name: player_name}}, socket}
        {:error, :duplicate_name} ->
          {:reply, {:error, %{reason: "Cannot join game with that name. Name is already taken."}}, socket}
        {:error, :already_started} ->
          {:reply, {:error, %{reason: "Cannot join game. Game is already started."}}, socket}
      end
    end
  end

  def handle_in("start", %{}, socket) do
    race = get_race(socket)
    # TODO(Havvy): Check if game is already started.
    # TODO(Havvy): Check if player has ability to start game.
    Gald.Race.begin(race)
    {:reply, {:ok, %{}}, socket}
  end

  def handle_in("option", ~m{option}, socket) do
    if option != "Confirm" do
      {:reply, {:error, %{reason: "Cannot do anything other than confirm."}}, socket}
    else
      # race = get_race(socket)
      # TODO(Havvy): Pass option to Player.In.
      {:reply, {:ok, %{}}, socket}
    end
  end

  def handle_in(message, payload, socket) do
    {:reply, {:error, %{reason: "Unknown message", message: message, payload: payload}}, socket}
  end

  # TODO(Havvy): Have the RaceManager monitor the channel process instead?
  def terminate({:shutdown, left_or_closed}, socket) do
    Logger.debug("Client channel connection closing.")
    GaldSite.RaceManager.delete_viewer(get_internal_name(socket), socket.transport_pid)
    {:shutdown, left_or_closed}
  end
  def terminate(reason, _socket) do
    Logger.warn("RaceChannel.terminated malignantly: #{inspect reason}")
  end
end