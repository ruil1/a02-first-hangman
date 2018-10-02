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
  defp check_letter(_, false),     do: "_"

  defp handle_guess(game, guess) do
    game
    |> update_state(guess)
    |> return_state(game, guess)
  end

  defp update_state(game, guess) do
    check_state(
      game.letters,
      tally(update_used(game, guess)).letters,
      game.turns_left,
      check_used(game, guess),
      check_correct(game, guess)
    )
  end

  defp check_used(game, guess),    do: Enum.member?(game.used, guess)
  defp check_correct(game, guess), do: Enum.member?(game.letters, guess)

  defp check_state(letters, letters, _, _, _), do: :won
  defp check_state(_, _, 1, _, _),             do: :lost
  defp check_state(_, _, _, true, _),          do: :already_used
  defp check_state(_, _, _, _, true),          do: :good_guess
  defp check_state(_, _, _, _, _),             do: :bad_guess

  defp return_state(state, game, guess) do
    %Hangman.Game.State{ game |
      game_state: state,
      turns_left: update_turn(game, state),
      used: update_used(game, guess, state),
      last_guess: guess
    }
  end

  defp update_turn(game, :lost),      do: game.turns_left - 1
  defp update_turn(game, :bad_guess), do: game.turns_left - 1
  defp update_turn(game, _),          do: game.turns_left

  defp update_used(game, _, :already_used), do: game.used
  defp update_used(game, guess, _),         do: update_used(game, guess).used
  defp update_used(game, guess) do
    %Hangman.Game.State{ game |
      used: game.used
        |> MapSet.new()
        |> MapSet.put(guess)
        |> MapSet.to_list()
        |> Enum.sort()
    }
  end

end
