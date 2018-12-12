defmodule ExChecker.Piece do
  @moduledoc """
  Models a chess piece
  """

  defstruct [rank: nil, color: nil, has_moved: false]

  @rank_abbrev [king: "K", queen: "Q", bishop: "B", knight: "N", rook: "R", pawn: "P"]

  @bishop_moves [
    (for n <- 1..7, do: {n, n}),
    (for n <- 1..7, do: {-n, -n}),
    (for n <- 1..7, do: {n, -n}),
    (for n <- 1..7, do: {-n, n})
  ]
  @rook_moves [
    (for y <- 1..7, do: {0, y}),
    (for y <- 1..7, do: {0, -y}),
    (for x <- 1..7, do: {x, 0}),
    (for x <- 1..7, do: {-x, 0})
  ]
  @white_pawn_capture_moves [[{1, 1, :capture}], [{-1, 1, :capture}]]
  @black_pawn_capture_moves [[{1, -1, :capture}], [{-1, -1, :capture}]]

  def new(rank, color) do
    %__MODULE__{rank: rank, color: color}
  end

  def bq, do: queen(:black)
  def bk, do: king(:black)
  def bb, do: bishop(:black)
  def br, do: rook(:black)
  def bp, do: pawn(:black)
  def bn, do: knight(:black)
  def wq, do: queen(:white)
  def wk, do: king(:white)
  def wb, do: bishop(:white)
  def wr, do: rook(:white)
  def wp, do: pawn(:white)
  def wn, do: knight(:white)

  def queen(color), do: new(:queen, color)
  def king(color), do: new(:king, color)
  def rook(color), do: new(:rook, color)
  def bishop(color), do: new(:bishop, color)
  def knight(color), do: new(:knight, color)
  def pawn(color), do: new(:pawn, color)

  def possible_moves(%__MODULE__{rank: :king}) do
    [[{0, 1}], [{1, 1}], [{1, 0}], [{1, -1}], [{0, -1}], [{-1, -1}], [{-1, 0}], [{-1,  1}]]
  end

  def possible_moves(%__MODULE__{rank: :knight}) do
    [[{1, 2}], [{2, 1}], [{2, -1}], [{1, -2}], [{-1, -2}], [{-2, -1}], [{-2, 1}], [{-1, 2}]]
  end

  def possible_moves(%__MODULE__{rank: :rook}), do: @rook_moves

  def possible_moves(%__MODULE__{rank: :bishop}), do: @bishop_moves

  def possible_moves(%__MODULE__{rank: :queen}) do
    @rook_moves ++ @bishop_moves
  end

  def possible_moves(%__MODULE__{rank: :pawn, color: :white, has_moved: false}) do
    [[{0, 1}, {0, 2}]] ++ @white_pawn_capture_moves
  end
  def possible_moves(%__MODULE__{rank: :pawn, color: :white, has_moved: true}) do
    [[{0, 1}]] ++ @white_pawn_capture_moves
  end
  def possible_moves(%__MODULE__{rank: :pawn, color: :black, has_moved: false}) do
    [[{0, -1}, {0, -2}]] ++ @black_pawn_capture_moves
  end
  def possible_moves(%__MODULE__{rank: :pawn, color: :black, has_moved: true}) do
    [[{0, -1}]] ++ @black_pawn_capture_moves
  end

  def to_string(nil), do: ""
  def to_string(%{rank: rank, color: color}) do
    with abbrev <- Keyword.get(@rank_abbrev, rank) do
      case color do
        :white -> abbrev
        :black -> String.downcase(abbrev)
      end
    end
  end
end
