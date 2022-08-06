defmodule ImplGameTest do
  use ExUnit.Case, async: true
  alias Hangman.Impl.Game

  setup do
    %{word: "batman"}
  end

  test "should return game struct" do
    assert %Game{
             turns_left: 7,
             game_state: :initializing,
             letters: letters
           } = Game.init_game()

    assert length(letters) > 0
  end

  test "should return the correct word", %{word: word} do
    assert %Game{
             letters: word
           } = Game.init_game(word)

    assert word == ["b", "a", "t", "m", "a", "n"]
  end

  test "state doens't change if a game is lost or won", %{word: word} do
    for state <- [:won, :lost] do
      game = Game.init_game(word)
      game = Map.put(game, :game_state, state)

      {new_game, _tally} = Game.make_move(game, "b")
      assert new_game == game
    end
  end

  test "should return :already_used state in repeated guess", %{word: word} do
    game = Game.init_game(word)

    {game, _tally} = Game.make_move(game, "b")
    {game, _tally} = Game.make_move(game, "b")
    assert game.game_state == :already_used
  end

  test "should mantain our guesses in used property", %{word: word} do
    game = Game.init_game(word)

    {game, _tally} = Game.make_move(game, "b")
    {game, _tally} = Game.make_move(game, "a")

    assert MapSet.equal?(game.used, MapSet.new(["a", "b"]))
  end

  test "should return :good_guess state on a good guess", %{word: word} do
    game = Game.init_game(word)

    {game, _tally} = Game.make_move(game, "b")

    assert game.game_state == :good_guess
  end

  test "should return :bad_guess state on a bad guess", %{word: word} do
    %{turns_left: turns} = game = Game.init_game(word)

    {game, _tally} = Game.make_move(game, "y")

    assert game.game_state == :bad_guess
    assert game.turns_left == turns - 1
  end

  test "should return :lost state on no turns left", %{word: word} do
    game = Game.init_game(word)
    game = %{game | turns_left: 1}
    {game, _tally} = Game.make_move(game, "y")
    assert game.game_state == :lost
  end

  test "should update state correctly between guesses", %{word: word} do
    # guess | state | turns | letters | used
    [
      ["a", :good_guess, 7, ["_", "a", "_", "_", "a", "_"], ["a"]],
      ["b", :good_guess, 7, ["b", "a", "_", "_", "a", "_"], ["a", "b"]],
      ["z", :bad_guess, 6, ["b", "a", "_", "_", "a", "_"], ["a", "b", "z"]],
      ["t", :good_guess, 6, ["b", "a", "t", "_", "a", "_"], ["a", "b", "t", "z"]]
    ]
    |> test_sequence_of_moves(word)
  end

  test "should return :won when used is a subset of letters", %{word: word} do
    # guess | state | turns | letters | used
    [
      ["a", :good_guess, 7, ["_", "a", "_", "_", "a", "_"], ["a"]],
      ["b", :good_guess, 7, ["b", "a", "_", "_", "a", "_"], ["a", "b"]],
      ["z", :bad_guess, 6, ["b", "a", "_", "_", "a", "_"], ["a", "b", "z"]],
      ["t", :good_guess, 6, ["b", "a", "t", "_", "a", "_"], ["a", "b", "t", "z"]],
      ["m", :good_guess, 6, ["b", "a", "t", "m", "a", "_"], ["a", "b", "m", "t", "z"]],
      ["n", :won, 6, ["b", "a", "t", "m", "a", "n"], ["a", "b", "m", "n", "t", "z"]]
    ]
    |> test_sequence_of_moves(word)
  end

  test "should return :lost when used is a subset of letters", %{word: word} do
    # guess | state | turns | letters | used
    [
      ["a", :good_guess, 7, ["_", "a", "_", "_", "a", "_"], ["a"]],
      ["b", :good_guess, 7, ["b", "a", "_", "_", "a", "_"], ["a", "b"]],
      ["z", :bad_guess, 6, ["b", "a", "_", "_", "a", "_"], ["a", "b", "z"]],
      ["t", :good_guess, 6, ["b", "a", "t", "_", "a", "_"], ["a", "b", "t", "z"]],
      ["m", :good_guess, 6, ["b", "a", "t", "m", "a", "_"], ["a", "b", "m", "t", "z"]],
      ["y", :bad_guess, 5, ["b", "a", "t", "m", "a", "_"], ["a", "b", "m", "t", "y", "z"]],
      ["y", :already_used, 5, ["b", "a", "t", "m", "a", "_"], ["a", "b", "m", "t", "y", "z"]],
      ["p", :bad_guess, 4, ["b", "a", "t", "m", "a", "_"], ["a", "b", "m", "p", "t", "y", "z"]],
      [
        "q",
        :bad_guess,
        3,
        ["b", "a", "t", "m", "a", "_"],
        ["a", "b", "m", "p", "q", "t", "y", "z"]
      ],
      [
        "r",
        :bad_guess,
        2,
        ["b", "a", "t", "m", "a", "_"],
        ["a", "b", "m", "p", "q", "r", "t", "y", "z"]
      ],
      [
        "s",
        :bad_guess,
        1,
        ["b", "a", "t", "m", "a", "_"],
        ["a", "b", "m", "p", "q", "r", "s", "t", "y", "z"]
      ],
      [
        "l",
        :lost,
        0,
        ["b", "a", "t", "m", "a", "n"],
        ["a", "b", "l", "m", "p", "q", "r", "s", "t", "y", "z"]
      ]
    ]
    |> test_sequence_of_moves(word)
  end

  def test_sequence_of_moves(script, word) do
    game = Game.init_game(word)

    script
    |> Enum.reduce(game, &check_one_move/2)
  end

  defp check_one_move([guess, state, turns, letters, used], game) do
    {game, tally} = Game.make_move(game, guess)

    assert %{game_state: ^state, turns_left: ^turns, letters: ^letters, used: ^used} = tally

    game
  end
end
