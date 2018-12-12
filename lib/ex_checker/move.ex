defmodule ExChecker.Move do
  @moduledoc """
  Models a single chess move
  """

  defstruct [
    color: nil, from: nil, to: nil, capture: nil, check: nil,
    castle: nil, piece: nil, en_passant: nil, original: ""
  ]

  def parse_move(color, "O-O"), do: %__MODULE__{castle: :kingside, color: color}
  def parse_move(color, "O-O-O"), do: %__MODULE__{castle: :queenside, color: color}

  def parse_move(color, "K" <> rest), do: parse_move(color, :king, rest)
  def parse_move(color, "Q" <> rest), do: parse_move(color, :queen, rest)
  def parse_move(color, "R" <> rest), do: parse_move(color, :rook, rest)
  def parse_move(color, "N" <> rest), do: parse_move(color, :knight, rest)
  def parse_move(color, "B" <> rest), do: parse_move(color, :bishop, rest)
  def parse_move(color, move), do: parse_move(color, :pawn, move)

  def parse_move(color, piece, move) do
    # case String.ends_with?(move, "+") do
    cond do
      String.match?(move, ~r/(\+|\#)$/) -> parse_move(color, piece, String.replace(move, ~r/(\+|\#)$/, ""))
      String.match?(move, ~r/x/) -> parse_capture_move(color, piece, move)
      true -> parse_regular_move(color, piece, move)
    end
  end

  defp parse_capture_move(color, piece, move) do
    [from, to] = String.split(move, "x")
    case from do
      "" -> {piece, to, :capture}
      _ -> {piece, from, to, :capture}
    end
  end

  defp parse_regular_move(color, piece, move) do
    %{"from" => from, "to" => to} = Regex.named_captures(~r/(?<from>.*)(?<to>..)$/, move)
    case from do
      "" -> {piece, to}
      _ -> {piece, from, to}
    end
  end
end
