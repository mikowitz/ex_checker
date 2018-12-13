defmodule ExChecker.GameTest do
  use ExUnit.Case, async: true

  alias ExChecker.{Game, Move}
  doctest Game

  test "run_pgn" do
    Game.run_pgn("test/assets/chandler_kasparov.pgn")
  end
end
