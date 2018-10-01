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
  def tally(game = %Hangman.Game.State{game_state: :won}),  do: game
  def tally(game = %Hangman.Game.State{game_state: :lost}),  do: game
  def tally(game = %Hangman.Game.State{}) do
    letters = update_letters(game.letters, game.used)
    %Hangman.Game.State{ game | letters: letters }
  end

  # returns a tuple containing the updated game state and a tally
  def make_move(game = %Hangman.Game.State{}, guess) do
    updated_game = handle_guess(game, guess)
    { updated_game, tally(updated_game) }
  end


  # helpers

  defp new_word() do
    Dictionary.random_word()
    |> String.codepoints()
  end

  defp update_letters(letters, used) do
    letters
    |> Enum.map(&check_letter(&1, Enum.member?(used, &1)))
  end

  defp check_letter(letter, true), do: letter
  defp check_letter(_, false), do: "_"

  defp handle_guess(game, guess) do
    new_state = update_state(game, guess)
    %Hangman.Game.State{ game |
      game_state: new_state,
      turns_left: update_turn(game, new_state),
      used: update_used(game, guess, new_state),
      last_guess: guess
    }
  end

  defp update_state(game, guess) do
    new_state = %Hangman.Game.State{ game |
      used: [ guess | game.used ]
        |> Enum.sort()
    }

    check_status(
      check_used(game.used, guess),
      game.letters,
      tally(new_state).letters,
      game.turns_left,
      check_correct(game.letters, guess))
  end

  defp update_turn(game, :lost),      do: game.turns_left - 1
  defp update_turn(game, :bad_guess), do: game.turns_left - 1
  defp update_turn(game, _),          do: game.turns_left

  defp update_used(game, _, :already_used), do: game.used
  defp update_used(game, guess, _) do
    %Hangman.Game.State{ game |
      used: game.used
        |> MapSet.new()
        |> MapSet.put(guess)
        |> MapSet.to_list()
        |> Enum.sort(),
    }
  end

  defp check_used(used, guess),       do: Enum.member?(used, guess)
  defp check_correct(letters, guess), do: Enum.member?(letters, guess)

  defp check_status(true, _, _, _, _),    do: :already_used
  defp check_status(_, word, word, _, _), do: :won
  defp check_status(_, _, _, 1, _),       do: :lost
  defp check_status(_, _, _, _, true),    do: :good_guess
  defp check_status(_, _, _, _, _),       do: :bad_guess

end
