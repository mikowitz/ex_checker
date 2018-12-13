defmodule ExChecker.Board do
  @moduledoc """
  Models a chess board and the pieces on it.
  """
  alias __MODULE__
  alias ExChecker.{CastleHelper, EnPassantHelper, Helpers}

  defstruct Enum.map(List.flatten(Helpers.ordered_squares()), fn sq -> {sq, nil} end)


  def new(config \\ ExChecker.BoardConfigurations.standard_configuration()) do
    Enum.reduce(config, %__MODULE__{}, fn {square, piece}, board ->
      Map.put(board, square, piece)
    end)
  end


  def kingside_castle(board, color) do
    CastleHelper.perform(board, color, :kingside)
  end

  def queenside_castle(board, color) do
    CastleHelper.perform(board, color, :queenside)
  end

  def all_pieces(board) do
    Helpers.ordered_squares()
    |> List.flatten
    |> Enum.map(fn key ->
      case Map.get(board, key) do
        nil -> []
        piece -> {key, piece}
      end
    end)
    |> List.flatten()
  end

  def inspect(board) do
    board |> ExChecker.Unicode.to_unicode() |> IO.puts()
    board
  end
end
