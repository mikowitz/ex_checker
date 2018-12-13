defmodule ExChecker.CastleHelper do

  alias ExChecker.Piece

  @squares [
    kingside: %{king: :e, rook: :h, intermediary: [:g, :f]},
    queenside: %{king: :e, rook: :a, intermediary: [:c, :d, :b]}
  ]
  @ranks [white: 1, black: 8]

  def kingside_castle(board, color) do
    state(board, color, :kingside)
  end

  def queenside_castle(board, color) do
    state(board, color, :queenside)
  end

  def state(board, color, side) do
    case check_king_and_rook(board, color, side) do
      false -> :impossible
      true ->
        case check_intermediary(board, color, side) do
          true -> :possible
          false -> :potential
        end
    end
  end

  def perform(board, color, side) do
    case state(board, color, side) do
      :possible ->
        %{king: ks, rook: rs, intermediary: [ke, re | _]} = @squares[side]
        rank = @ranks[color]
        king = Map.get(board, :"#{ks}#{rank}")
        rook = Map.get(board, :"#{rs}#{rank}")
        board
        |> Map.put(:"#{ke}#{rank}", %{king | has_moved: true})
        |> Map.put(:"#{re}#{rank}", %{rook | has_moved: true})
        |> Map.put(:"#{ks}#{rank}", nil)
        |> Map.put(:"#{rs}#{rank}", nil)
      _ -> board
    end
  end

  defp check_king_and_rook(board, color, side) do
    %{king: kf, rook: rf} = @squares[side]
    rank = @ranks[color]
    Enum.map([kf, rf], fn file ->
      Map.get(board, :"#{file}#{rank}")
    end) == [
      %Piece{rank: :king, color: color, has_moved: false},
      %Piece{rank: :rook, color: color, has_moved: false}
    ]
  end

  defp check_intermediary(board, color, side) do
    %{intermediary: files} = @squares[side]
    rank = @ranks[color]
    Enum.all?(files, fn file ->
      Map.get(board, :"#{file}#{rank}") == nil
    end)
  end
end
