defmodule HangmanTest do
  use ExUnit.Case
  doctest Hangman

  test "start a new game" do
    assert Hangman.new_game().game_state == :initializing
    assert Hangman.new_game().turns_left == 7
    assert Hangman.new_game().letters != []
  end
end
