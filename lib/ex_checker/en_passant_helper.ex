defmodule ExChecker.EnPassantHelper do
  alias ExChecker.Helpers

  def find_en_passant_moves_for(board, move) do
    board
    |> possible_en_passant_moves_to(move.to)
    |> ExChecker.MoveHelper.filter_moves_by_origin(move)
  end

  def is_valid_en_passant_move(board, piece, from, to) do
    to in valid_en_passant_moves(piece, from, board)
  end

  def valid_en_passant_moves(piece, from, board) do
    [x, y] = to_charlist(from)

    piece
    |> ExChecker.Piece.possible_moves()
    |> Enum.map(fn moves ->
      Enum.reduce_while(moves, [], fn
        {dx, dy}, acc ->
          ExChecker.MoveHelper.handle_regular_move({x, y}, {dx, dy}, board, piece, acc)

        {dx, dy, :capture}, acc ->
          ExChecker.MoveHelper.handle_regular_move({x, y}, {dx, dy}, board, piece, acc)
      end)
    end)
    |> List.flatten()
  end

  def possible_en_passant_moves_to(board, to) do
    to = Helpers.to_atom(to)
    board
    |> ExChecker.Board.all_pieces
    |> Enum.map(fn {k, piece} ->
      cond do
        k == to -> []
        piece.rank != :pawn -> []
        true -> check_valid_en_passant_move(board, piece, k, to)
      end
    end)
    |> List.flatten()
  end

  def check_valid_en_passant_move(board, piece, k, to) do
    case is_valid_en_passant_move(board, piece, k, to) do
      true -> {k, piece}
      false -> []
    end
  end

  def en_passant_target_square(capture_end, :white) do
    {tr, tf} = Helpers.rank_file(capture_end)
    :"#{tf}#{tr - 1}"
  end

  def en_passant_target_square(capture_end, :black) do
    {tr, tf} = Helpers.rank_file(capture_end)
    :"#{tf}#{tr + 1}"
  end

end
