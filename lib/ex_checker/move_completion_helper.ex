defmodule ExChecker.MoveCompletionHelper do
  alias ExChecker.{EnPassantHelper, Helpers}

  def complete_move(game, move = %{piece: :pawn}) do
    case to_string(move.to) == to_string(game.en_passant_square) do
      true -> do_complete_en_passant_move(game.board, move)
      false -> do_complete_regular_move(game.board, move)
    end
  end
  def complete_move(_game, move = %{original: ""}), do: move
  def complete_move(_game, move = %{castle: :kingside}), do: move
  def complete_move(_game, move = %{castle: :queenside}), do: move
  def complete_move(game, move), do: do_complete_regular_move(game.board, move)

  def is_valid_move(board, piece, from, to) do
    Helpers.to_atom(to) in valid_moves(piece, from, board)
  end

  def possible_moves_to(board, to) do
    board
    |> ExChecker.Board.all_pieces()
    |> Enum.map(fn {k, piece} ->
      case k == Helpers.to_atom(to) do
        true -> []
        false -> check_valid_move(board, piece, k, to)
      end
    end)
    |> List.flatten()
  end

  def check_valid_move(board, piece, k, to) do
    case is_valid_move(board, piece, k, to) do
      true -> {k, piece}
      false -> []
    end
  end

  def filter_moves_by_origin(possible_moves, move) do
    Enum.filter(possible_moves, fn {k, piece} ->
      piece.color == move.color && piece.rank == move.piece &&
        k |> to_string |> String.match?(Regex.compile!(to_string(move.from)))
    end)
  end

  def handle_regular_move(coord, delta, board, piece, acc) do
    handle_any_move(coord, delta, board, piece, acc, false)
  end

  defp do_complete_en_passant_move(board, move) do
    {from, %{rank: :pawn}} =
      board
      |> EnPassantHelper.find_en_passant_moves_for(move)
      |> List.first()
    %{move | from: from, en_passant: true}
  end

  defp do_complete_regular_move(board, move) do
    {from, _piece} =
      board
      |> find_moves_for(move)
      |> List.first()
    %{move | from: from}
  end

  defp find_moves_for(board, move) do
    board
    |> possible_moves_to(Helpers.to_atom(move.to))
    |> filter_moves_by_origin(move)
  end

  defp valid_moves(piece, from, board) do
    [x, y] = to_charlist(from)

    piece
    |> ExChecker.Piece.possible_moves()
    |> Enum.map(fn moves ->
      Enum.reduce_while(moves, [], fn
        {dx, dy}, acc ->
          handle_regular_move({x, y}, {dx, dy}, board, piece, acc)

        {dx, dy, :capture}, acc ->
          handle_capture_move({x, y}, {dx, dy}, board, piece, acc)
      end)
    end)
    |> List.flatten()
  end

  defp handle_capture_move(coord, delta, board, piece, acc) do
    handle_any_move(coord, delta, board, piece, acc, true)
  end

  defp handle_any_move({x, y}, {dx, dy}, board, piece, acc, is_capture) do
    to = [nx, ny] = [x + dx, y + dy]
    to_atom = Helpers.to_atom(to)

    case nx < ?a || nx > ?h || ny < ?1 || ny > ?8 do
      true -> {:halt, acc}
      false -> handle_in_bounds_move(board, to_atom, piece, acc, is_capture)
    end
  end

  defp handle_in_bounds_move(board, to_atom, piece, acc, is_capture) do
    case Map.get(board, to_atom) do
      nil ->
        case is_capture do
          true -> {:halt, acc}
          false -> {:cont, [to_atom | acc]}
        end

      target_piece ->
        case target_piece.color == piece.color do
          true -> {:halt, acc}
          false -> {:halt, [to_atom | acc]}
        end
    end
  end
end
