defmodule Hangman.Runtime.Server do
  alias Hangman.Impl.Game
  use GenServer

  @type t() :: pid()

  # Client process
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  # Server process
  def init(_) do
    {:ok, Game.init_game()}
  end

  def handle_call({:make_move, guess}, _from, state) do
    {updated_state, tally} = Game.make_move(state, guess)
    {:reply, tally, updated_state}
  end

  def handle_call({:tally}, _from, state) do
    {:reply, Game.tally(state), state}
  end
end
