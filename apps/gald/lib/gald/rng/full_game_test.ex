defmodule Gald.Rng.FullGameTest do
  @moduledoc false
  
  use GenServer

  def start_link(%{}, otp_opts) do
    GenServer.start_link(__MODULE__, %{}, otp_opts)
  end

  def init(%{}) do
    {:ok, [
      5, # @P1 Round 1 DiceRoll, 1st die;
      5, # @P1 Round 1 DiceRoll, 2nd die;
      5, # @P2 Round 1 DiceRoll, 1st die;
      5, # @P2 Round 1 DiceRoll, 2nd die;
      5, # @P1 Round 2 DiceRoll, 1st die;
      5, # @P1 Round 2 DiceRoll, 2nd die;
      5, # @P2 Round 2 DiceRoll, 1st die;
      5, # @P2 Round 2 DiceRoll, 2nd die;
      5, # @P1 Round 3 DiceRoll, 1st die;
      5, # @P1 Round 3 DiceRoll, 2nd die;
    ]}
  end

  def handle_call({:positive_int, i}, _from, [reply | state]) do
    {:reply, reply, state}
  end
end