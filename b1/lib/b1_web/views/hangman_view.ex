defmodule B1Web.HangmanView do
  use B1Web, :view

  @status_fields %{
    initializing: {"initializing", "Guess the word, a letter a a time"},
    good_guess: {"good-guess", "Good guess!"},
    bad_guess: {"bad-guess", "Sorry, that's a bad guess"},
    won: {"won", "You won!"},
    lost: {"lost", "Sorry, you lost"},
    already_used: {"already-used", "You already used that letter"}
  }

  defdelegate figure_for(attempts), to: B1Web.HangmanHelpers.FigureFor

  def move_status(status) do
    {class, message} = @status_fields[status]
    "<div class='status #{class}'> #{message} </div>"
  end

  def continue_or_try_again(conn, status) when status in [:won, :lost] do
    button("Try again", to: Routes.hangman_path(conn, :new))
  end

  def continue_or_try_again(conn, _status) do
    form_for(conn, Routes.hangman_path(conn, :update), [as: "make_move", method: :put], fn f ->
      [text_input(f, :guess), submit("Make next guess")]
    end)
  end
end
