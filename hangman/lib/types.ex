defmodule Hangman.Types do
  @type state :: :initializing | :good_guess | :bad_guess | :already_used | :win | :lose | :error

  @type tally :: %{
          turns_left: integer(),
          game_state: state,
          letters: list(String.t()),
          used: list(String.t())
        }
end
