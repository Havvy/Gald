defprotocol Gald.Usable do
  @moduledoc """
  Usables are things that can show up in the inventory - consumables, abilities, equipment, etc.
  """

  @spec name(Gald.Usable.t) :: String.t
  def name(self)
end