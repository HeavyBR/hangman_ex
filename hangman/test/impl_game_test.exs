defmodule ImplGameTest do
  use ExUnit.Case, async: true
  alias Hangman.Impl.Game

  test "should return game struct" do
    assert %Game{
             turns_left: 7,
             game_state: :initializing,
             letters: letters
           } = Game.init_game()

    assert length(letters) > 0
  end

  test "should return the correct word" do
    assert %Game{
             letters: word
           } = Game.init_game("batman")

    assert word == ["b", "a", "t", "m", "a", "n"]
  end

  test "state doens't change if a game is lost or won" do
    for state <- [:won, :lost] do
      game = Game.init_game("batman")
      game = Map.put(game, :game_state, state)

      {new_game, _tally} = Game.make_move(game, "b")
      assert new_game == game
    end
  end

  test "should return :already_used state in repeated guess" do
    game = Game.init_game("batman")

    {game, _tally} = Game.make_move(game, "b")
    {game, _tally} = Game.make_move(game, "b")
    assert game.game_state == :already_used
  end

  test "should mantain our guesses in used property" do
    game = Game.init_game("batman")

    {game, _tally} = Game.make_move(game, "b")
    {game, _tally} = Game.make_move(game, "a")

    assert MapSet.equal?(game.used, MapSet.new(["a", "b"]))
  end
end
