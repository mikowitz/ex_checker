defmodule ExChecker.FEN.Writer do
  @moduledoc """
  Provides the ability to write the state of a chess game to FEN.
  """

  alias ExChecker.{CastleHelper, Helpers, Piece}

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
    |> Enum.map(&(&1.(game)))
    |> Enum.join(" ")
  end

  defp do_write_board_square(board, square, {str, empty_count}) do
    case Map.get(board, square) do
      nil -> {str, empty_count + 1}
      piece ->
        {
          str <> empty_count_string(empty_count) <> Piece.to_string(piece),
          0
        }
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
      with {row, empty_count} <- do_write_board_rank(game.board, squares) do
        row <> empty_count_string(empty_count)
      end
    end)
    |> Enum.join("/")
  end

  defp empty_count_string(0), do: ""
  defp empty_count_string(n), do: "#{n}"

  defp do_write_turn(%{turn: :white}), do: "w"
  defp do_write_turn(%{turn: :black}), do: "b"

  defp do_write_castles(game) do
    available_castles =
      [
        {CastleHelper.state(game.board, :white, :kingside), "K"},
        {CastleHelper.state(game.board, :white, :queenside), "Q"},
        {CastleHelper.state(game.board, :black, :kingside), "k"},
        {CastleHelper.state(game.board, :black, :queenside), "q"},
      ]
      |> Enum.map(fn {bool, abbrev} ->
        case bool do
          :impossible -> nil
          _ -> abbrev
        end
      end)

    case Enum.all?(available_castles, &is_nil/1) do
      true -> "-"
      false -> Enum.join(available_castles, "")
    end
  end

  defp do_write_en_passant(%{en_passant_square: nil}), do: "-"
  defp do_write_en_passant(%{en_passant_square: square}), do: "#{square}"

  defp do_write_moveclocks(game), do: "#{game.halfmove} #{game.fullmove}"
end
