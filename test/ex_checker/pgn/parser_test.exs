defmodule ExChecker.PGN.ParserTest do
  use ExUnit.Case, async: true

  alias ExChecker.PGN.Parser

  test "parses a basic file" do
    parsed = Parser.parse!("test/assets/chandler_kasparov.pgn")

    assert parsed.metadata["Result"] == "1-0"
    [white, black] = parsed.game[1]
    assert white.original == "e4"
    assert black.original == "c5"
  end
end
