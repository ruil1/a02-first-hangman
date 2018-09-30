defmodule Hangman.Game do

  defmodule State do
    defstruct(
      game_state:    :initializing,
      turns_left:    7,
      letters:       [],
      used:          [],
      last_guess:    ""
    )
  end

  # API

  # returns a struct representing a new game
  def new_game() do
    %Hangman.Game.State{letters: new_word()}
  end

  # returns the tally for the given game

  # returns a tuple containing the updated game state and a tally


  # helpers

  def new_word() do
    Dictionary.random_word()
    |> String.codepoints()
  end

end
