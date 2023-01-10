defmodule ImplGameTest do
  use ExUnit.Case

  alias Hangman.Impl.Game

  doctest Hangman.Impl.Game

  describe "new_game" do
    test "should return a new game" do
      assert Game.new_game() |> Map.delete(:letters) ==
               %Game{} |> Map.delete(:letters)

      ng = Game.new_game()

      assert ng |> Map.get(:letters) ==
               ng |> Map.get(:letters) |> Enum.map(&String.downcase/1)
    end

    test "should return a new game with a correct word" do
      assert Game.new_game("wombat") |> Map.get(:letters) == ["w", "o", "m", "b", "a", "t"]
    end
  end

  describe "get_tally" do
    test "should return a correct tally for initialized game" do
      game = %Game{letters: ["w", "o", "m", "b", "a", "t"]}

      assert Game.get_tally(game) ==
               %{
                 turns_left: 7,
                 game_state: :initializing,
                 letters: ["_", "_", "_", "_", "_", "_"],
                 used: []
               }
    end

    test "should return a correct tally for mid game" do
      game = %Game{letters: ["w", "o", "m", "b", "a", "t"], used: MapSet.new(["t", "a"])}

      assert Game.get_tally(game) ==
               %{
                 turns_left: 7,
                 game_state: :initializing,
                 letters: ["_", "_", "_", "_", "a", "t"],
                 used: ["a", "t"]
               }
    end
  end

  describe "make_move" do
    test "things don't change if state is won" do
      game = Game.new_game("wombat") |> Map.put(:game_state, :win)
      tally = Game.get_tally(game)
      assert Game.make_move(game, "a") == {game, tally}
    end

    test "things don't change if state is lost" do
      game = Game.new_game("wombat") |> Map.put(:game_state, :lose)
      tally = Game.get_tally(game)
      assert Game.make_move(game, "a") == {game, tally}
    end

    test "should return already_used for already used letters" do
      game =
        Game.new_game("wombat")
        |> Map.put(:game_state, :playing)
        |> Map.put(:used, MapSet.new(["a"]))

      {new_game, _} = Game.make_move(game, "a")
      assert new_game.game_state == :already_used
    end

    test "should return an updated list of letters for new letters" do
      game =
        Game.new_game("wombat")
        |> Map.put(:game_state, :playing)
        |> Map.put(:used, MapSet.new(["a"]))

      {new_game, _} = Game.make_move(game, "b")
      assert MapSet.equal?(new_game.used, MapSet.new(["a", "b"]))
    end

    test "should return return :good_guesss state on good guess" do
      game = Game.new_game("wombat") |> Map.put(:game_state, :playing)
      {new_game, _} = Game.make_move(game, "b")
      assert new_game.game_state == :good_guess
    end

    test "should return return :bad_guess state on bad guess" do
      game = Game.new_game("wombat") |> Map.put(:game_state, :playing)
      {new_game, _} = Game.make_move(game, "z")
      assert new_game.game_state == :bad_guess
    end

    test "should return return :win state on win" do
      game = Game.new_game("w") |> Map.put(:game_state, :playing)
      {new_game, _} = Game.make_move(game, "w")
      assert new_game.game_state == :win
    end

    test "should return return :lose state on lose" do
      game = Game.new_game("w") |> Map.put(:game_state, :playing) |> Map.put(:turns_left, 1)
      {new_game, _} = Game.make_move(game, "z")
      assert new_game.game_state == :lose
    end

    test "should successfully play the game from start to win" do
      game = Game.new_game("wombat") |> Map.put(:game_state, :playing)

      {game, tally} = Game.make_move(game, "a")
      assert game.game_state == :good_guess
      assert tally.letters == ["_", "_", "_", "_", "a", "_"]
      {game, tally} = Game.make_move(game, "b")
      assert game.game_state == :good_guess
      assert tally.letters == ["_", "_", "_", "b", "a", "_"]
      {game, tally} = Game.make_move(game, "t")
      assert game.game_state == :good_guess
      assert tally.letters == ["_", "_", "_", "b", "a", "t"]
      {game, tally} = Game.make_move(game, "p")
      assert game.game_state == :bad_guess
      assert tally.letters == ["_", "_", "_", "b", "a", "t"]
      assert game.turns_left == 6
      {game, tally} = Game.make_move(game, "q")
      assert game.game_state == :bad_guess
      assert tally.letters == ["_", "_", "_", "b", "a", "t"]
      assert game.turns_left == 5
      {game, tally} = Game.make_move(game, "w")
      assert game.game_state == :good_guess
      assert tally.letters == ["w", "_", "_", "b", "a", "t"]
      {game, tally} = Game.make_move(game, "t")
      assert game.game_state == :already_used
      assert tally.letters == ["w", "_", "_", "b", "a", "t"]
      assert game.turns_left == 5
      {game, tally} = Game.make_move(game, "o")
      assert game.game_state == :good_guess
      assert tally.letters == ["w", "o", "_", "b", "a", "t"]
      {game, tally} = Game.make_move(game, "m")
      assert game.game_state == :win
      assert tally.letters == ["w", "o", "m", "b", "a", "t"]
    end

    test "should successfully play the game from start to lose" do
      game = Game.new_game("wombat") |> Map.put(:game_state, :playing)
      {game, tally} = Game.make_move(game, "a")
      assert game.game_state == :good_guess
      assert tally.letters == ["_", "_", "_", "_", "a", "_"]
      {game, tally} = Game.make_move(game, "b")
      assert game.game_state == :good_guess
      assert tally.letters == ["_", "_", "_", "b", "a", "_"]
      {game, tally} = Game.make_move(game, "t")
      assert game.game_state == :good_guess
      assert tally.letters == ["_", "_", "_", "b", "a", "t"]
      {game, tally} = Game.make_move(game, "p")
      assert game.game_state == :bad_guess
      assert tally.letters == ["_", "_", "_", "b", "a", "t"]
      assert game.turns_left == 6
      {game, tally} = Game.make_move(game, "q")
      assert game.game_state == :bad_guess
      assert tally.letters == ["_", "_", "_", "b", "a", "t"]
      assert game.turns_left == 5
      {game, tally} = Game.make_move(game, "s")
      assert game.game_state == :bad_guess
      assert tally.letters == ["_", "_", "_", "b", "a", "t"]
      assert game.turns_left == 4
      {game, tally} = Game.make_move(game, "r")
      assert game.game_state == :bad_guess
      assert tally.letters == ["_", "_", "_", "b", "a", "t"]
      assert game.turns_left == 3
      {game, tally} = Game.make_move(game, "n")
      assert game.game_state == :bad_guess
      assert tally.letters == ["_", "_", "_", "b", "a", "t"]
      assert game.turns_left == 2
      {game, tally} = Game.make_move(game, "y")
      assert game.game_state == :bad_guess
      assert tally.letters == ["_", "_", "_", "b", "a", "t"]
      assert game.turns_left == 1
      {game, tally} = Game.make_move(game, "z")
      assert game.turns_left == 0
      assert game.game_state == :lose
      assert tally.letters == ["_", "_", "_", "b", "a", "t"]
    end
  end
end
