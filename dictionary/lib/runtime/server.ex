defmodule Dictionary.Runtime.Server do
  alias Dictionary.Impl.Random

  @type t :: pid()

  def start_link() do
    Agent.start_link(&Random.start/0, name: __MODULE__)
  end

  def random_word() do
    Agent.get(__MODULE__, &Random.random_word/1)
  end
end
