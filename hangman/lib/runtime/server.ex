defmodule Hangman.Runtime.Server do
  alias Hangman.Impl.Game
  alias Hangman.Runtime.Watchdog
  use GenServer

  @idle_timeout 1 * 60 * 1000

  @type t() :: pid()

  # Client process
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  # Server process
  def init(_) do
    {:ok, {Game.init_game(), Watchdog.start(@idle_timeout)}}
  end

  def handle_call({:make_move, guess}, _from, {state, watchdog}) do
    Watchdog.im_alive(watchdog)
    {updated_state, tally} = Game.make_move(state, guess)
    {:reply, tally, updated_state}
  end

  def handle_call({:tally}, _from, {state, watchdog}) do
    Watchdog.im_alive(watchdog)
    {:reply, Game.tally(state), state}
  end
end
