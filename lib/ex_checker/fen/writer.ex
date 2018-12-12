defmodule ExChecker.FEN.Writer do
  @moduledoc """
  Provides the ability to write the state of a chess game to FEN.
  """

  alias ExChecker.{Helpers, Piece}

  @doc """

      iex> game = ExChecker.Game.new
      iex> ExChecker.FEN.Writer.write(game)
      "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

  """
  def write(game) do
    [
      &do_write_board/1,
      &do_write_turn/1,
      &do_write_castles/1,
      &do_write_en_passant/1,
      &do_write_moveclocks/1
    ]
    |> Enum.map(& &1.(game))
    |> Enum.join(" ")
  end

  defp do_write_board_square(board, square, {str, empty_count}) do
    case Map.get(board, square) do
      nil ->
        {str, empty_count + 1}

      piece ->
        case empty_count do
          0 -> {str <> Piece.to_string(piece), 0}
          _ -> {str <> to_string(empty_count) <> Piece.to_string(piece), 0}
        end
    end
  end

  defp do_write_board_rank(board, squares) do
    Enum.reduce(squares, {"", 0}, fn square, acc ->
      do_write_board_square(board, square, acc)
    end)
  end

  defp do_write_board(game) do
    Helpers.ordered_squares()
    |> Enum.map(fn squares ->
      {row, empty_count} = do_write_board_rank(game.board, squares)

      case empty_count do
        0 -> row
        _ -> row <> to_string(empty_count)
      end
    end)
    |> Enum.join("/")
  end

  defp do_write_turn(%{turn: :white}), do: "w"
  defp do_write_turn(%{turn: :black}), do: "b"

  defp do_write_castles(game) do
    available_castles =
      [
        can_kingside_castle: [:white, "K"],
        can_queenside_castle: [:white, "Q"],
        can_kingside_castle: [:black, "k"],
        can_queenside_castle: [:black, "q"]
      ]
      |> Enum.map(fn {func, [color, abbrev]} ->
        case apply(__MODULE__, func, [game.board, color]) do
          true -> abbrev
          false -> ""
        end
      end)

    case Enum.all?(available_castles, fn c -> c == "" end) do
      true -> "-"
      false -> Enum.join(available_castles, "")
    end
  end

  # TODO
  defp do_write_en_passant(%{en_passant_square: nil}) do
    "-"
  end

  defp do_write_en_passant(%{en_passant_square: square}), do: to_string(square)

  defp do_write_moveclocks(game) do
    "#{game.halfmove} #{game.fullmove}"
  end

  def can_kingside_castle(board, :white) do
    case Enum.map([:e1, :h1], &Map.get(board, &1)) do
      [
        %{rank: :king, color: :white, has_moved: false},
        %{rank: :rook, color: :white, has_moved: false}
      ] ->
        true

      _ ->
        false
    end
  end

  def can_kingside_castle(board, :black) do
    case Enum.map([:e8, :h8], &Map.get(board, &1)) do
      [
        %{rank: :king, color: :black, has_moved: false},
        %{rank: :rook, color: :black, has_moved: false}
      ] ->
        true

      _ ->
        false
    end
  end

  def can_queenside_castle(board, :white) do
    case Enum.map([:a1, :e1], &Map.get(board, &1)) do
      [
        %{rank: :rook, color: :white, has_moved: false},
        %{rank: :king, color: :white, has_moved: false}
      ] ->
        true

      _ ->
        false
    end
  end

  def can_queenside_castle(board, :black) do
    case Enum.map([:a8, :e8], &Map.get(board, &1)) do
      [
        %{rank: :rook, color: :black, has_moved: false},
        %{rank: :king, color: :black, has_moved: false}
      ] ->
        true

      _ ->
        false
    end
  end
end
