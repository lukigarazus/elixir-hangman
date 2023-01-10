defmodule Dictionary do
  @word_list (case(File.read("assets/words.txt")) do
                {:error, _} -> []
                {:ok, data} -> data |> String.split(~r/\n/, trim: true)
              end)

  def get_word() do
    case @word_list do
      [] -> {:error, "No words found"}
      words -> {:ok, Enum.random(words)}
    end
  end
end
