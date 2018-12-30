defmodule ExChecker.Move do
  @moduledoc """
  Models a single chess move
  """

  alias ExChecker.Helpers

  defstruct color: nil,
            from: nil,
            to: nil,
            capture: nil,
            check: nil,
            castle: nil,
            piece: nil,
            en_passant: nil,
            original: ""

  def generate(map = %{piece: piece}) do
    struct(
      __MODULE__,
      Map.put(map, :piece, piece_from(piece))
    )
  end

  def is_capture(%__MODULE__{capture: "x"}), do: true
  def is_capture(_), do: false

  def is_pawn_two_square(%__MODULE__{piece: :pawn, from: from, to: to}) do
    {fr, ff} = Helpers.rank_file(from)
    {tr, tf} = Helpers.rank_file(to)
    ff == tf && abs(fr - tr) == 2
  end
  def is_pawn_two_square(_), do: false

  defp piece_from("K"), do: :king
  defp piece_from("Q"), do: :queen
  defp piece_from("R"), do: :rook
  defp piece_from("B"), do: :bishop
  defp piece_from("N"), do: :knight
  defp piece_from(_), do: :pawn
end
