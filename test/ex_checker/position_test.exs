defmodule ExChecker.PositionTest do
  use ExUnit.Case, async: true

  @starting_fen "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

  alias ExChecker.{Position, FEN.Parser}

  test "finds moves for a given FEN position" do
    position = Parser.parse(@starting_fen)

    # assert length(Position.available_moves(position)) == 20
    assert Position.available_moves(position) == [
      "a2a3", "a2a4",
      "b2b3", "b2b4",
      "c2c3", "c2c4",
      "d2d3", "d2d4",
      "e2e3", "e2e4",
      "f2f3", "f2f4",
      "g2g3", "g2g4",
      "h2h3", "h2h4",
      "Na3", "Nc3",
      "Nf3", "Nh3"
    ]
  end

  test "finds black moves for a given FEN postinio" do
    position = Parser.parse("rnbqkbnr/pppppppp/8/8/8/3P4/PPP1PPPP/RNBQKBNR b KQkq - 0 1")

    assert length(Position.available_moves(position)) == 20
    assert Position.available_moves(position) == [
      "Na6", "Nc6",
      "Nf6", "Nh6",
      "a7a6", "a7a5",
      "b7b6", "b7b5",
      "c7c6", "c7c5",
      "d7d6", "d7d5",
      "e7e6", "e7e5",
      "f7f6", "f7f5",
      "g7g6", "g7g5",
      "h7h6", "h7h5",
    ]

  end
end
