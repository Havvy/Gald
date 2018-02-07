defprotocol Gald.Equipable do
  @moduledoc """
  Things that can be equipped implement this protocol.
  """

  @doc "Which slot the equipable is equipped to."
  @spec slot(Equipable.t) :: Gald.Player.Equipment.slot
  def slot(self)
end