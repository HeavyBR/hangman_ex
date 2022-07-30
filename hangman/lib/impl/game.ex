defmodule Hangman.Impl.Game do
  require Logger
  alias Hangman.Types

  defstruct(
    turns_left: 7,
    game_state: :initializing,
    letters: [],
    used: MapSet.new()
  )

  @type t :: %__MODULE__{
          turns_left: integer(),
          game_state: Types.state(),
          letters: list(String.t()),
          used: MapSet.t()
        }

  #########################################################

  @spec init_game() :: t
  def init_game do
    init_game(Dictionary.random_word())
  end

  @spec init_game(String.t()) :: t
  def init_game(word) do
    %__MODULE__{
      letters: word |> String.graphemes()
    }
  end

  #########################################################

  @spec make_move(t(), String.t()) :: {t(), Types.tally()}
  def make_move(game = %{game_state: state}, _guess) when state in [:won, :lost] do
    return_with_tally(game)
  end

  def make_move(game, guess) do
    accept_guess(game, guess, MapSet.member?(game.used, guess))
    |> return_with_tally()
  end

  #########################################################

  def return_with_tally(game), do: {game, tally(game)}

  def tally(game) do
    %{
      turns_left: game.turns_left,
      game_state: game.game_state,
      letters: reveal_guesses_letters(game),
      used: game.used |> MapSet.to_list() |> Enum.sort()
    }
  end

  #########################################################
  def accept_guess(game, _guess, _already_used = true) do
    %{game | game_state: :already_used}
  end

  def accept_guess(game, guess, _already_used) do
    %{game | used: MapSet.put(game.used, guess)}
    |> score_guess(Enum.member?(game.letters, guess))
  end

  #########################################################

  defp score_guess(game, _good_guess = true) do
    new_state = maybe_won(MapSet.subset?(MapSet.new(game.letters), game.used))
    %{game | game_state: new_state}
  end

  defp score_guess(game = %{turns_left: 1}, _bad_guess) do
    %{game | game_state: :lost, turns_left: 0}
  end

  defp score_guess(game = %{turns_left: turns_left}, _bad_guess) do
    %{game | game_state: :bad_guess, turns_left: turns_left - 1}
  end

  #########################################################

  defp maybe_won(true), do: :won
  defp maybe_won(_), do: :good_guess

  defp maybe_reveal(true, letter), do: letter
  defp maybe_reveal(false, _), do: "_"

  #########################################################

  defp reveal_guesses_letters(game) do
    game.letters
    |> Enum.map(fn letter -> MapSet.member?(game.used, letter) |> maybe_reveal(letter) end)
  end
end
