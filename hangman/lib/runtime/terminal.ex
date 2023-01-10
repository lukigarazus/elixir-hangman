defmodule Hangman.Runtime.Terminal do
  defp get_char() do
    case IO.gets("Guess a letter\n") do
      {:error, _} ->
        IO.puts("Invalid input")
        get_char()

      :eof ->
        :exit

      data ->
        trimmed_data = data |> String.trim()

        case trimmed_data |> String.length() do
          0 ->
            :exit

          1 ->
            trimmed_data

          _ ->
            IO.puts("Too many characters")
            get_char()
        end
    end
  end

  def play(state) do
    char = get_char()

    case char do
      :exit ->
        IO.puts("Bye!")

      _ ->
        {new_state, tally} = Hangman.next_move(state, char)
        IO.puts(tally.letters |> Enum.join(""))
        IO.puts("Turns left: #{tally.turns_left}\n\n")

        case tally.game_state do
          :error ->
            IO.puts("Error")

          :win ->
            IO.puts("You win!")

          :lose ->
            IO.puts("You lose!")
            IO.puts("The word was: #{new_state.word |> Enum.join("")}")

          :good_guess ->
            IO.puts("Good guess!")
            play(new_state)

          :bad_guess ->
            IO.puts("Bad guess!")
            play(new_state)

          :playing ->
            play(new_state)
        end
    end
  end

  def start_game() do
    IO.puts("Welcome to Hangman!\n\n")
    play(Hangman.new_game())
  end
end
