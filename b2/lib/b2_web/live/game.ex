defmodule B2Web.Live.Game do
  alias B2Web.Live.Game.{Alphabet, Figure, WordSoFar}
  use B2Web, :live_view

  def mount(_params, _session, socket) do
    game = Hangman.new_game()
    tally = Hangman.tally(game)
    {:ok, assign(socket, %{game: game, tally: tally})}
  end

  def handle_event("make_move", %{"key" => key}, socket) do
    tally = IO.inspect(Hangman.make_move(socket.assigns.game, key))

    {:noreply, assign(socket, :tally, tally)}
  end
end
