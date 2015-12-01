defmodule Gald.Display.Battle do
  @moduledoc """
  The display used for combat.

  * player: A %Gald.Display.Battle.PlayerCard. Used to show the player card.
  * monster: A %Gald.Display.Battle.MonsterCard. Used to show the monster card.
  * previous_action_descriptions: A list of strings describing what happened during the previous action.
  """

  defstruct [
    monster: nil,
    player: nil,
    previous_action_descriptions: []
  ]

end

defmodule Gald.Display.Battle.PlayerCard do
  @moduledoc """
  Player stats shown during battle.
  """

  defstruct [
    name: nil,
    health: nil,
    max_health: nil,
    attack: nil,
    defense: nil,
    damage: nil
  ]
end

defmodule Gald.Display.Battle.MonsterCard do
  @moduledoc """
  Monster stats shown during battle.
  """

  defstruct [
    name: nil,
    health: nil,
    attack: nil,
    defense: nil,
  ]
end