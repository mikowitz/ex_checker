defmodule ExChecker.PGN.ParserTest do
  use ExUnit.Case, async: true

  alias ExChecker.{Move, PGN.Parser}

  test "parses a basic file" do
    parsed = Parser.parse!("test/assets/chandler_kasparov.pgn")

    assert parsed.metadata["Result"] == "1-0"
    [white, black] = parsed.game[1]
    assert white.original == "e4"
    assert black.original == "c5"
  end

  describe "parse_move/2" do
    test "parse a castle" do
      assert Parser.parse_move(:black, "O-O") == %Move{
        color: :black, from: nil, to: nil, capture: nil, check: nil,
        castle: :kingside, piece: nil, en_passant: nil, original: "O-O"
      }
    end

    test "parse a pawn move" do
      assert Parser.parse_move(:white, "e2") == %Move{
        color: :white, from: nil, to: "e2", capture: nil, check: nil,
        castle: nil, piece: :pawn, en_passant: nil, original: "e2"
      }
    end

    test "parse a capture" do
      assert Parser.parse_move(:black, "Qxe6") == %Move{
        color: :black, from: nil, to: "e6", capture: "x", check: nil,
        castle: nil, piece: :queen, en_passant: nil, original: "Qxe6"
      }
    end
  end
end
