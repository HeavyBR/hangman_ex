defmodule Dictionary do
  @split_token "\n"
  @word_list "assets/words.txt"
             |> File.read!()
             |> String.split(@split_token, trim: true)

  def random_word do
    @word_list
    |> Enum.random()
  end
end
