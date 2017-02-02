defprotocol Gald.Usable do
  @moduledoc """
  Usables are things that can show up in the inventory - consumables, abilities, equipment, etc.
  """

  @type usable_update :: Gald.Usable.t | :delete

  @spec name(Gald.Usable.t) :: String.t
  def name(self)

  @spec use(Gald.Usable.t, Supervisor.supervisor) :: usable_update
  def use(self, player)
end