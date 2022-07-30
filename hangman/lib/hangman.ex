defmodule Hangman do
  alias Hangman.Impl.Game
  alias Hangman.Types

  @opaque game :: Game.t()

  @spec new_game() :: game()
  defdelegate new_game, to: Game, as: :init_game

  @spec make_move(game, String.t()) :: {game, Types.tally()}
  defdelegate make_move(game, guess), to: Game
end
