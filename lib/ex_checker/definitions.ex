defmodule ExChecker.Definitions do
  @white_pawn 0
  @white_knight 1
  @white_bishop 2
  @white_rook 3
  @white_queen 4
  @white_king 5
  @black_pawn 6
  @black_knight 7
  @black_bishop 8
  @black_rook 9
  @black_queen 10
  @black_king 11
  @empty 12

  @white 0
  @black 1

  def white, do: @white
  def black, do: @black

  def wP, do: @white_pawn
  def wR, do: @white_rook
  def wN, do: @white_knight
  def wB, do: @white_bishop
  def wQ, do: @white_queen
  def wK, do: @white_king

  def bP, do: @black_pawn
  def bR, do: @black_rook
  def bN, do: @black_knight
  def bB, do: @black_bishop
  def bQ, do: @black_queen
  def bK, do: @black_king

  def empty, do: @empty
end
