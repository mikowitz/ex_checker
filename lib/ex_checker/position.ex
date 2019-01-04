defmodule ExChecker.Position do
  alias ExChecker.Definitions, as: D

  @board64to100 [
    1, 2, 3, 4, 5, 6, 7, 8,
    11,12,13,14,15,16,17,18,
    21,22,23,24,25,26,27,28,
    31,32,33,34,35,36,37,38,
    41,42,43,44,45,46,47,48,
    51,52,53,54,55,56,57,58,
    61,62,63,64,65,66,67,68,
    71,72,73,74,75,76,77,78
  ]

  @board100to64 [
    65, 0, 1, 2, 3, 4, 5, 6, 7,65,
    65, 8, 9,10,11,12,13,14,15,65,
    65,16,17,18,19,20,21,22,23,65,
    65,24,25,26,27,28,29,30,31,65,
    65,32,33,34,35,36,37,38,39,65,
    65,40,41,42,43,44,45,46,47,65,
    65,48,49,50,51,52,53,54,55,65,
    65,56,57,58,59,60,61,62,63,65,
    65,65,65,65,65,65,65,65,65,65,
    65,65,65,65,65,65,65,65,65,65
  ]

  defstruct [
    board: [],
    side: nil,
    castles: 0,
    ep: nil,
    halfmove: 0,
    fullmove: 0
  ]

  def new do
    cycle = Stream.cycle([D.empty])
    %__MODULE__{
      board: Enum.take(cycle, 64)
    }
  end

  def sq64to100(sq64) do
    Enum.at(@board64to100, sq64)
  end

  def sq100to64(sq100) do
    Enum.at(@board100to64, sq100)
  end

  @white 0
  @black 1

  def available_moves(position) do
    case position.side do
      @white -> available_white_moves(position)
      @black -> available_black_moves(position)
    end
  end

  def available_white_moves(position) do
    position.board
    |> Enum.with_index
    |> Enum.filter(fn {piece, _index} ->
      piece >= 0 && piece <= 5
    end)
    |> Enum.map(fn {piece, index} -> find_moves(piece, index, position) end)
    |> List.flatten
    |> Enum.reject(&is_nil/1)
  end

  def available_black_moves(position) do
    position.board
    |> Enum.with_index
    |> Enum.filter(fn {piece, _index} ->
      piece >= 6 && piece <= 11
    end)
    |> Enum.map(fn {piece, index} -> find_moves(piece, index, position) end)
    |> List.flatten
    |> Enum.reject(&is_nil/1)
  end

  def pawn_moves(:initial), do: [-10, -20]
  def pawn_moves, do: [-10]
  def knight_moves do
    [-21,-19,-12,-8,8,12,19,21]
  end

  def king_moves do
    [-11,-10,-9,-1,1,9,10,11]
  end

  def queen_moves do
    rook_moves() ++ bishop_moves()
  end

  def rook_moves do
    [-10,-1,1,10]
  end

  def bishop_moves do
    [-11,-9,9,11]
  end

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

  def find_moves(@white_pawn, index, position) do
    orig_index = index
    moves = cond do
      index in 48..55 -> pawn_moves(:initial)
      true -> pawn_moves()
    end
    Enum.map(moves, fn delta ->
      sq64to100(index) + delta
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.filter(fn index -> Enum.at(@board100to64, index) < 65 end)
    |> Enum.map(&sq100to64/1)
    |> Enum.map(fn index -> {index, ExChecker.FEN.Parser.index_to_sq_lookup(orig_index) <> ExChecker.FEN.Parser.index_to_sq_lookup(index)} end)
    |> Enum.filter(fn {index, _move} ->
      Enum.at(position.board, index) > 5
    end)
    |> Enum.map(fn {_, move} -> move end)
  end

  def find_moves(@white_knight, index, position) do
    Enum.map(knight_moves(), fn delta ->
      sq64to100(index) + delta
    end)
    |> Enum.filter(fn index -> Enum.at(@board100to64, index) < 65 end)
    |> Enum.map(&sq100to64/1)
    |> Enum.map(fn index -> {index, "N" <> ExChecker.FEN.Parser.index_to_sq_lookup(index)} end)
    |> Enum.filter(fn {index, _move} ->
      Enum.at(position.board, index) > 5
    end)
    |> Enum.map(fn {_, move} -> move end)
  end

  def find_moves(@white_bishop, index, position) do
    Enum.map(bishop_moves(), fn delta ->
      check_slide_moves(index, delta, position, "B", @white)
    end)
  end

  def find_moves(@white_rook, index, position) do
    Enum.map(rook_moves(), fn delta ->
      check_slide_moves(index, delta, position, "R", @white)
    end)
  end
  def find_moves(@white_queen, index, position) do
    Enum.map(queen_moves(), fn delta ->
      check_slide_moves(index, delta, position, "Q", @white)
    end)
  end
  def find_moves(@white_king, index, position) do
    Enum.map(king_moves(), fn delta ->
      sq64to100(index) + delta
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.filter(fn index -> Enum.at(@board100to64, index) < 65 end)
    |> Enum.map(&sq100to64/1)
    |> Enum.map(fn index -> {index, "N" <> ExChecker.FEN.Parser.index_to_sq_lookup(index)} end)
    |> Enum.filter(fn {index, _move} ->
      Enum.at(position.board, index) > 5
    end)
    |> Enum.map(fn {_, move} -> move end)
  end

  def find_moves(@black_pawn, index, position) do
    orig_index = index
    moves = cond do
      index in 8..15 -> pawn_moves(:initial)
      true -> pawn_moves()
    end
    Enum.map(moves, fn delta ->
      sq64to100(index) - delta
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.filter(fn index -> Enum.at(@board100to64, index) < 65 end)
    |> Enum.map(&sq100to64/1)
    |> Enum.map(fn index -> {index, ExChecker.FEN.Parser.index_to_sq_lookup(orig_index) <> ExChecker.FEN.Parser.index_to_sq_lookup(index)} end)
    |> Enum.filter(fn {index, _move} ->
      Enum.at(position.board, index) > 5
    end)
    |> Enum.map(fn {_, move} -> move end)
  end

  def find_moves(@black_knight, index, position) do
    Enum.map(knight_moves(), fn delta ->
      sq64to100(index) + delta
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.filter(fn index -> Enum.at(@board100to64, index) < 65 end)
    |> Enum.map(&sq100to64/1)
    |> Enum.map(fn index -> {index, "N" <> ExChecker.FEN.Parser.index_to_sq_lookup(index)} end)
    |> Enum.filter(fn {index, _move} ->
      Enum.at(position.board, index) <= 5 || Enum.at(position.board, index) == @empty
    end)
    |> Enum.map(fn {_, move} -> move end)
  end
  def find_moves(@black_bishop, index, position) do
    Enum.map(bishop_moves(), fn delta ->
      check_slide_moves(index, delta, position, "B", @black)
    end)
  end
  def find_moves(@black_rook, index, position) do
    Enum.map(rook_moves(), fn delta ->
      check_slide_moves(index, delta, position, "R", @black)
    end)
  end
  def find_moves(@black_queen, index, position) do
    Enum.map(queen_moves(), fn delta ->
      check_slide_moves(index, delta, position, "Q", @black)
    end)
  end
  def find_moves(@black_king, index, position) do
    Enum.map(king_moves(), fn delta ->
      sq64to100(index) + delta
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.filter(fn index -> Enum.at(@board100to64, index) < 65 end)
    |> Enum.map(&sq100to64/1)
    |> Enum.map(fn index -> {index, "N" <> ExChecker.FEN.Parser.index_to_sq_lookup(index)} end)
    |> Enum.filter(fn {index, _move} ->
      Enum.at(position.board, index) <= 5 || Enum.at(position.board, index) == @empty
    end)
    |> Enum.map(fn {_, move} -> move end)
  end

  def check_slide_moves(index, delta, position, prefix, color) do
    Enum.map(1..7, fn x -> x * delta end)
    |> Enum.reduce_while([], fn slide_delta, moves ->
      new_i = sq64to100(index) + slide_delta
      case Enum.at(@board100to64, new_i) < 65 do
        false -> {:halt, moves}
        true ->
          index = sq100to64(new_i)
          case [Enum.at(position.board, index), color] do
            [@empty, _] -> {:cont, [{index, prefix <> ExChecker.FEN.Parser.index_to_sq_lookup(index)}|moves]}
            [n, @black] when n <= 5 -> {:halt, [{index, prefix <> ExChecker.FEN.Parser.index_to_sq_lookup(index)}|moves]}
            [n, @white] when n > 5 -> {:halt, [{index, prefix <> ExChecker.FEN.Parser.index_to_sq_lookup(index)}|moves]}
            _ -> {:halt, moves}
          end
      end
    end)
  end
end
