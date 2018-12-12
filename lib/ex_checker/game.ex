defmodule ExChecker.Game do
  @moduledoc """
  Models a standard game of chess.
  """

  defstruct board: ExChecker.Board.new(),
            turn: :white,
            halfmove: 0,
            fullmove: 1,
            en_passant_square: nil,
            metadata: %{}

  alias __MODULE__
  alias ExChecker.{Board, Helpers, Move}
  alias ExChecker.PGN.Parser

  @doc """

      iex> game = ExChecker.Game.new
      iex> ExChecker.FEN.Writer.write(game)
      "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

  """
  def new, do: %__MODULE__{}

  @doc """

      iex> game = Game.new
      iex> {:error, _, error} = Game.move(game, %Move{piece: :pawn, color: :black, from: :e2, to: :e4})
      iex> error
      :whites_turn

      iex> game = Game.new
      iex> {:ok, game} = Game.move(game, %Move{piece: :pawn, color: :white, from: :c2, to: :c4})
      iex> game.turn
      :black

  """
  def move(game = %Game{turn: :white}, %Move{color: :black}), do: {:error, game, :whites_turn}
  def move(game = %Game{turn: :black}, %Move{color: :white}), do: {:error, game, :blacks_turn}

  def move(game, move) do
    move = Board.complete_move(game.board, game.turn, move, game.en_passant_square)

    game = %{
      game
      | board: Board.perform_move(game.board, game.turn, move),
        turn: toggle_turn(game.turn)
    }

    game =
      cond do
        is_capture(move) ->
          %{game | halfmove: 0, en_passant_square: nil}

        is_pawn_two_square(move) ->
          en_passant_square = en_passant_square(move.to, move.color)
          %{game | halfmove: 0, en_passant_square: en_passant_square}

        true ->
          %{game | halfmove: game.halfmove + 1, en_passant_square: nil}
      end

    {:ok, game}
  end

  defp toggle_turn(:black), do: :white
  defp toggle_turn(:white), do: :black

  def run_pgn(filename) do
    %{game: turns, metadata: md} = Parser.parse!(filename)
    game = %Game{metadata: md}

    turns
    |> Enum.sort_by(fn {k, _} -> k end)
    |> Enum.reduce(game, fn {_turn_no, [white, black]}, game ->
      {:ok, game} = move(game, white)
      {:ok, game} = move(game, black)
      %{game | fullmove: game.fullmove + 1}
    end)
  end

  defp is_capture(%Move{capture: "x"}), do: true
  defp is_capture(_), do: false

  defp is_pawn_two_square(%Move{piece: :pawn, from: from, to: to}) do
    {fr, ff} = Helpers.rank_file(from)
    {tr, tf} = Helpers.rank_file(to)
    ff == tf && abs(fr - tr) == 2
  end

  defp is_pawn_two_square(_), do: false

  def en_passant_square(capture_end, :white) do
    {tr, tf} = Helpers.rank_file(capture_end)
    :"#{tf}#{tr - 1}"
  end

  def en_passant_square(capture_end, :black) do
    {tr, tf} = Helpers.rank_file(capture_end)
    :"#{tf}#{tr + 1}"
  end
end
