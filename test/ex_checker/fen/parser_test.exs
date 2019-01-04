defmodule ExChecker.FEN.ParserTest do
  use ExUnit.Case, async: true

  alias ExChecker.FEN.Parser
  alias ExChecker.Definitions, as: P

  @starting_fen "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

  test "parsing the starting position" do
    position = Parser.parse(@starting_fen)

    assert is_nil(position.ep)
    assert position.halfmove == 0
    assert position.fullmove == 1
    assert position.side == P.white
    assert position.castles == 15
    assert position.board == [
      P.bR, P.bN, P.bB, P.bQ, P.bK, P.bB, P.bN, P.bR,
      P.bP, P.bP, P.bP, P.bP, P.bP, P.bP, P.bP, P.bP,
      P.empty, P.empty, P.empty, P.empty, P.empty, P.empty, P.empty, P.empty,
      P.empty, P.empty, P.empty, P.empty, P.empty, P.empty, P.empty, P.empty,
      P.empty, P.empty, P.empty, P.empty, P.empty, P.empty, P.empty, P.empty,
      P.empty, P.empty, P.empty, P.empty, P.empty, P.empty, P.empty, P.empty,
      P.wP, P.wP, P.wP, P.wP, P.wP, P.wP, P.wP, P.wP,
      P.wR, P.wN, P.wB, P.wQ, P.wK, P.wB, P.wN, P.wR
    ]
  end

  test "parsing with an en passant square" do
    position = Parser.parse("rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1")

    assert position.ep == 44
    assert position.halfmove == 0
    assert position.fullmove == 1
    assert position.side == P.black
    assert position.castles == 15
    assert position.board == [
      P.bR, P.bN, P.bB, P.bQ, P.bK, P.bB, P.bN, P.bR,
      P.bP, P.bP, P.bP, P.bP, P.bP, P.bP, P.bP, P.bP,
      P.empty, P.empty, P.empty, P.empty, P.empty, P.empty, P.empty, P.empty,
      P.empty, P.empty, P.empty, P.empty, P.empty, P.empty, P.empty, P.empty,
      P.empty, P.empty, P.empty, P.empty, P.wP, P.empty, P.empty, P.empty,
      P.empty, P.empty, P.empty, P.empty, P.empty, P.empty, P.empty, P.empty,
      P.wP, P.wP, P.wP, P.wP, P.empty, P.wP, P.wP, P.wP,
      P.wR, P.wN, P.wB, P.wQ, P.wK, P.wB, P.wN, P.wR
    ]

  end

  test "parsing the middle of the game" do
    position = Parser.parse("rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2")

    assert is_nil(position.ep)
    assert position.halfmove == 1
    assert position.fullmove == 2
    assert position.side == P.black
    assert position.castles == 15
    assert position.board == [
      P.bR, P.bN, P.bB, P.bQ, P.bK, P.bB, P.bN, P.bR,
      P.bP, P.bP, P.empty, P.bP, P.bP, P.bP, P.bP, P.bP,
      P.empty, P.empty, P.empty, P.empty, P.empty, P.empty, P.empty, P.empty,
      P.empty, P.empty, P.bP, P.empty, P.empty, P.empty, P.empty, P.empty,
      P.empty, P.empty, P.empty, P.empty, P.wP, P.empty, P.empty, P.empty,
      P.empty, P.empty, P.empty, P.empty, P.empty, P.wN, P.empty, P.empty,
      P.wP, P.wP, P.wP, P.wP, P.empty, P.wP, P.wP, P.wP,
      P.wR, P.wN, P.wB, P.wQ, P.wK, P.wB, P.empty, P.wR
    ]
  end
end
