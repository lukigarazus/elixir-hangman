defmodule Hangman.Impl.Game do
  @type t :: %__MODULE__{
          turns_left: integer(),
          game_state: Hangman.Types.state(),
          letters: list(String.t()),
          used: MapSet.t(String.t())
        }

  defstruct(
    turns_left: 7,
    game_state: :initializing,
    letters: [],
    used: MapSet.new()
  )

  # -------------------------------------------------------

  def new_game() do
    case Dictionary.get_word() do
      {:error, _} -> []
      {:ok, word} -> word |> new_game()
    end
  end

  def new_game(word) do
    %__MODULE__{
      letters: word |> String.codepoints()
    }
  end

  # -------------------------------------------------------

  def make_move(game = %{game_state: :initializing}, _) do
    game |> Map.put(:game_state, :playing) |> return_with_tally()
  end

  def make_move(game = %{game_state: state}, _) when state in [:win, :lose] do
    game |> return_with_tally()
  end

  def make_move(game, guess) do
    game |> accept_guess(guess, game.used |> MapSet.member?(guess)) |> return_with_tally()
  end

  # -------------------------------------------------------

  defp accept_guess(game, guess, _already_used = true) do
    game |> Map.put(:game_state, :already_used)
  end

  defp accept_guess(game, guess, _already_used = false) do
    game
    |> Map.put(:used, game.used |> MapSet.put(guess))
    |> score_guess(Enum.member?(game.letters, guess))
  end

  # -------------------------------------------------------

  defp score_guess(game, _good_guess = true) do
    game
    |> Map.put(:game_state, :good_guess)
    |> score_good_guess(MapSet.subset?(MapSet.new(game.letters), game.used))
  end

  defp score_guess(game, _bad_guess = false) do
    new_turns_left = game.turns_left - 1

    game
    |> Map.put(:turns_left, new_turns_left)
    |> Map.put(:game_state, :bad_guess)
    |> score_bad_guess(new_turns_left)
  end

  # -------------------------------------------------------

  defp score_good_guess(game, _every_letter_used = true) do
    game |> Map.put(:game_state, :win)
  end

  defp score_good_guess(game, _every_letter_used = false) do
    game
  end

  # -------------------------------------------------------

  defp score_bad_guess(game, _turns_left = 0) do
    game |> Map.put(:game_state, :lose)
  end

  defp score_bad_guess(game, _turns_left) do
    game
  end

  # -------------------------------------------------------

  defp return_with_tally(game) do
    {game, get_tally(game)}
  end

  # -------------------------------------------------------

  def get_tally(game) do
    used = game |> Map.get(:used)

    %{
      turns_left: game.turns_left,
      game_state: game.game_state,
      letters:
        game.letters
        |> Enum.map(fn letter ->
          if used |> MapSet.member?(letter) do
            letter
          else
            "_"
          end
        end),
      used: used |> MapSet.to_list() |> Enum.sort()
    }
  end
end
