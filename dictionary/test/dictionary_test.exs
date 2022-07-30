defmodule DictionaryTest do
  use ExUnit.Case
  doctest Dictionary

  test "should return a random word" do
    assert is_binary(Dictionary.random_word())
  end
end
