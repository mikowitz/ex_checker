defmodule ExChecker.MoveHelper do
  @moduledoc """
  Helper functions relating to moving pieces.
  """

  alias ExChecker.{Board, Helpers, MoveCompletionHelper}

  # perform_move

  def perform_move(game, move) do
    case move do
      %{castle: :kingside} ->
        Board.kingside_castle(game.board, move.color)

      %{castle: :queenside} ->
        Board.queenside_castle(game.board, move.color)

      %{from: from, to: to, color: color, en_passant: true} ->
        existing_pawn_location = ExChecker.EnPassantHelper.en_passant_target_square(to, color)
        pawn = Map.get(game.board, from)

        game.board
        |> Map.put(existing_pawn_location, nil)
        |> Map.put(Helpers.to_atom(to), pawn)
        |> Map.put(Helpers.to_atom(from), nil)

      _ ->
        move(game.board, move)
    end
  end

  defp move(board, %{from: nil, to: nil}), do: board
  defp move(board, %{from: from, to: to}) do
    from = Helpers.to_atom(from)
    to = Helpers.to_atom(to)
    case Map.get(board, from) do
      nil -> {:error, board, :no_piece_to_move}
      piece = %{color: color} -> do_move_piece(board, piece, from, to, color)
    end
  end

  defp do_move_piece(board, piece, from, to, color) do
    case Map.get(board, to) do
      %ExChecker.Piece{color: ^color} -> {:error, board, :invalid_move}

      _ ->
        case MoveCompletionHelper.is_valid_move(board, piece, from, to) do
          false ->
            {:error, board, :invalid_move}

          true ->
            piece = Map.get(board, from)
            piece = %{piece | has_moved: true}
            Map.put(board, to, piece)
            |> Map.put(from, nil)
        end
    end
  end
end
