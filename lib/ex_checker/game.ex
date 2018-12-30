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

  alias ExChecker.{Game, Move, PGN.Parser}

  @doc """

      iex> game = ExChecker.Game.new
      iex> ExChecker.FEN.Writer.write(game)
      "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

  """
  def new, do: %__MODULE__{}

  def run_pgn(filename) do
    %{game: turns, metadata: md} = Parser.parse!(filename)
    game = %Game{metadata: md}

    File.open("#{filename}.txt", [:write], fn file ->
      IO.write(file, "#{ExChecker.Weighter.print_weights(game.board)}\n")
      turns
      |> Enum.reduce(game, fn [white, black], game ->
        IO.inspect "#{white.original} #{black.original}"
        {:ok, game} = move(game, white)
        IO.write(file, "#{ExChecker.Weighter.print_weights(game.board)}\n")
        game = case move(game, black) do
          {:ok, game} -> game
          {:error, game, _} -> game
        end
        IO.write(file, "#{ExChecker.Weighter.print_weights(game.board)}\n")
        %{game | fullmove: game.fullmove + 1}
      end)
    end)
  end

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
  def move(game = %Game{turn: color}, move = %Move{color: color}) do
    move = ExChecker.MoveCompletionHelper.complete_move(game, move)

    game = %{
      game
      | board: ExChecker.MoveHelper.perform_move(game, move)
    } |> toggle_turn

    game =
      cond do
        Move.is_capture(move) -> %{game | halfmove: 0, en_passant_square: nil}
        Move.is_pawn_two_square(move) ->
          %{game |
            halfmove: 0,
            en_passant_square: ExChecker.EnPassantHelper.en_passant_target_square(move.to, move.color)
          }
        true ->
          %{game | halfmove: game.halfmove + 1, en_passant_square: nil}
      end

    {:ok, game}
  end
  def move(game = %Game{turn: color}, %Move{}), do: {:error, game, :"#{color}s_turn"}

  defp toggle_turn(game = %{turn: :black}), do: %{game | turn: :white}
  defp toggle_turn(game = %{turn: :white}), do: %{game | turn: :black}


  def can_kingside_castle(board, color) do
    ExChecker.CastleHelper.kingside_castle(board, color) in [:potential, :possible]
  end
  def can_queenside_castle(board, color) do
    ExChecker.CastleHelper.queenside_castle(board, color) in [:potential, :possible]
  end
end
