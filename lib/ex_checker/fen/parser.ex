defmodule ExChecker.FEN.Parser do
  @white 0
  @black 1

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

  alias ExChecker.Position

  def parse(fen_str) do
    fen_segments = String.split(fen_str, " ", trim: true)
    case fen_segments do
      [board, side, castles, ep, halfmove, fullmove] ->
        Position.new
        |> parse_board(board)
        |> parse_side(side)
        |> parse_castling(castles)
        |> parse_ep(ep)
        |> parse_halfmove(halfmove)
        |> parse_fullmove(fullmove)
      _ -> {:error, :invalid_fen_string, fen_str}
    end
  end

  def parse_board(position, board_str) do
    {position, _} = Enum.reduce(to_charlist(board_str), {position, 0}, fn char, {position, index} ->
      {piece, new_index} = case char do
        ?r -> {@black_rook, index}
        ?n -> {@black_knight, index}
        ?b -> {@black_bishop, index}
        ?q -> {@black_queen, index}
        ?k -> {@black_king, index}
        ?p -> {@black_pawn, index}
        ?R -> {@white_rook, index}
        ?N -> {@white_knight, index}
        ?B -> {@white_bishop, index}
        ?Q -> {@white_queen, index}
        ?K -> {@white_king, index}
        ?P -> {@white_pawn, index}
        ?/ -> {@empty, index}
        n when n in ?1..?8 -> {@empty, index + n - ?0}
        _ -> {:error, :unexpected_board_character, char}
      end

      case piece do
        @empty -> {position, new_index}
        piece ->
          new_board = List.replace_at(position.board, new_index, piece)
          new_position = %{position | board: new_board}
          {new_position, new_index + 1}
      end
    end)
    position
  end

  def parse_halfmove(position, halfmove) do
    with {hm, ""} <- Integer.parse(halfmove) do
      %{position | halfmove: hm}
    end
  end

  def parse_fullmove(position, fullmove) do
    with {fm, ""} <- Integer.parse(fullmove) do
      %{position | fullmove: fm}
    end
  end

  def parse_castling(position, "-"), do: position
  def parse_castling(position, castles) do
    castles = castles
    |> to_charlist
    |> Enum.reduce(0, fn char, total ->
      case char do
        ?K -> total + 8
        ?Q -> total + 4
        ?k -> total + 2
        ?q -> total + 1
      end
    end)
    %{position | castles: castles}
  end

  def parse_side(position, "w"), do: %{position | side: @white}
  def parse_side(position, "b"), do: %{position | side: @black}

  def parse_ep(position, "-"), do: position
  def parse_ep(position, ep) do
    %{position | ep: sq_to_index_lookup(ep)}
  end

  # TODO: should this be a lookup table? and globally available?
  # (?8 - r) * 8 + (f - ?a)

  @sq_lookup %{
    "a1" => 56, "b1" => 57, "c1" => 58, "d1" => 59, "e1" => 60, "f1" => 61, "g1" => 62, "h1" => 63,
    "a2" => 48, "b2" => 49, "c2" => 50, "d2" => 51, "e2" => 52, "f2" => 53, "g2" => 54, "h2" => 55,
    "a3" => 40, "b3" => 41, "c3" => 42, "d3" => 43, "e3" => 44, "f3" => 45, "g3" => 46, "h3" => 47,
    "a4" => 32, "b4" => 33, "c4" => 34, "d4" => 35, "e4" => 36, "f4" => 37, "g4" => 38, "h4" => 39,
    "a5" => 24, "b5" => 25, "c5" => 26, "d5" => 27, "e5" => 28, "f5" => 29, "g5" => 30, "h5" => 31,
    "a6" => 16, "b6" => 17, "c6" => 18, "d6" => 19, "e6" => 20, "f6" => 21, "g6" => 22, "h6" => 23,
    "a7" => 8,  "b7" => 9,  "c7" => 10, "d7" => 11, "e7" => 12, "f7" => 13, "g7" => 14, "h7" => 15,
    "a8" => 0,  "b8" => 1,  "c8" => 2,  "d8" => 3,  "e8" => 4,  "f8" => 5,  "g8" => 6,  "h8" => 7
  }
  @sq_lookup_reverse Enum.map(@sq_lookup, fn {k, v} -> {v, k} end) |> Enum.sort_by(fn {k, _} -> k end) |> Enum.map(fn {_, v} -> v end)

  def sq_to_index_lookup(str), do: Map.get(@sq_lookup, str)
  def index_to_sq_lookup(index), do: Enum.at(@sq_lookup_reverse, index)
end
