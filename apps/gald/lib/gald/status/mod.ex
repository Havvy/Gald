defprotocol Gald.Status do
  @typep option(t) :: t | nil
  @typep one_or_many(t) :: t | [t]
  @type on_turn_start_args :: %{required(:stats) => Player.Stats.t, required(:player_name) => Player.name}
  @type on_turn_start_ret :: %{
    required(:log) => option(one_or_many(String.t)),
    required(:body) => option(one_or_many(String.t))
  }

  @doc "Display name of status."
  @spec name(Gald.Status.t) :: String.t
  def name(status)

  @doc "When true, this status is not removed by death."
  @spec soulbound(Gald.Status.t) :: boolean
  def soulbound(status)

  @doc "Whether or not this status has on player turn start effects."
  @spec has_on_turn_start(Gald.Status.t) :: boolean
  def has_on_turn_start(status)

  @doc "Actually do the on player turn start thing."
  @spec on_turn_start(Gald.Status.t, on_turn_start_args) :: on_turn_start_ret
  def on_turn_start(status, player)

  @spec is(t, atom) :: boolean
  Kernel.def is(%status_module{}, status_module), do: true
  Kernel.def is(_status, _status_module), do: false
end

defmodule Gald.Status.Mixin do
  defmacro __using__(_opts) do
    module = __CALLER__.module |> Module.split() |> List.last()
    quote do
      alias Gald.Status

      def name(_status), do: unquote(module)

      def soulbound(_status), do: false

      def has_on_turn_start(_status), do: false
      def on_turn_start(_status, _player), do: %{}

      defoverridable [
        name: 1,
        soulbound: 1,
        has_on_turn_start: 1,
        on_turn_start: 2
      ]
    end
  end
end