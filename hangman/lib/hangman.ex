defmodule Hangman do
  alias Hangman.Impl.Game

  @opaque game :: Game.t()

  @spec new_game() :: Hangman.Types.game()
  defdelegate new_game, to: Game

  @spec make_move(game, String.t()) :: {game, Hangman.Types.tally()}
  defdelegate make_move(game, guess), to: Game
end
