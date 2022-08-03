defmodule Dictionary.Impl.Random do
  @split_token "\n"

  @type t :: list(String.t())

  @spec start() :: t()
  def start do
    "assets/words.txt"
    |> File.read!()
    |> String.split(@split_token, trim: true)
  end

  @spec random_word(Types.state()) :: String.t()
  def random_word(word_list) do
    word_list
    |> Enum.random()
  end
end
