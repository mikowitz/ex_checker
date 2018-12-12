defmodule ExChecker.Unicode do
  @moduledoc """
  Helper module for displaying chess pieces and boards in Unicode characters.
  """

  alias ExChecker.Helpers

  def board(board = %ExChecker.Board{}) do
    Helpers.ordered_squares()
    |> Enum.map(fn squares ->
      squares
      |> Enum.map(fn square ->
        board |> Map.get(square) |> to_unicode
      end)
      |> Enum.join(" ")
    end)
    |> Enum.join("\n")
  end

  def piece(piece = %ExChecker.Piece{}), do: to_unicode(piece)

  defp to_unicode(nil), do: "_"
  defp to_unicode(%{rank: :pawn, color: :white}), do: "♙"
  defp to_unicode(%{rank: :king, color: :white}), do: "♔"
  defp to_unicode(%{rank: :queen, color: :white}), do: "♕"
  defp to_unicode(%{rank: :rook, color: :white}), do: "♖"
  defp to_unicode(%{rank: :knight, color: :white}), do: "♘"
  defp to_unicode(%{rank: :bishop, color: :white}), do: "♗"

  defp to_unicode(%{rank: :pawn, color: :black}), do: "♟"
  defp to_unicode(%{rank: :king, color: :black}), do: "♚"
  defp to_unicode(%{rank: :queen, color: :black}), do: "♛"
  defp to_unicode(%{rank: :rook, color: :black}), do: "♜"
  defp to_unicode(%{rank: :knight, color: :black}), do: "♞"
  defp to_unicode(%{rank: :bishop, color: :black}), do: "♝"
end
