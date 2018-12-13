defmodule ExChecker.CastleHelperTest do
  use ExUnit.Case, async: true

  alias ExChecker.{Board, CastleHelper}

  describe ".state/3" do
    test "for a new board, all 4 castles are potential" do
      board = Board.new()

      assert CastleHelper.state(board, :white, :kingside) == :potential
      assert CastleHelper.state(board, :white, :queenside) == :potential
      assert CastleHelper.state(board, :black, :kingside) == :potential
      assert CastleHelper.state(board, :black, :queenside) == :potential
    end

    test "is possible if there are no intermediary pieces" do

      board = Board.new()
              |> Map.put(:f1, nil)
              |> Map.put(:g1, nil)

      assert CastleHelper.state(board, :white, :kingside) == :possible
      assert CastleHelper.state(board, :white, :queenside) == :potential
    end

    test "is impossible if the king has moved" do
      board = Board.new()
              |> Map.update(:e8, nil, fn map -> %{map | has_moved: true} end)

      assert CastleHelper.state(board, :black, :kingside) == :impossible
      assert CastleHelper.state(board, :black, :queenside) == :impossible
    end

    test "is impossible if the rook has moved" do
      board = Board.new()
              |> Map.update(:a8, nil, fn map -> %{map | has_moved: true} end)

      assert CastleHelper.state(board, :black, :kingside) == :potential
      assert CastleHelper.state(board, :black, :queenside) == :impossible
    end

    test "is impossible if the rook is not in position" do
      board = Board.new()
              |> Map.put(:a1, nil)

      assert CastleHelper.state(board, :white, :kingside) == :potential
      assert CastleHelper.state(board, :white, :queenside) == :impossible
    end
  end


  describe ".perform/3" do
    test "does nothing on a new board" do
      board = Board.new()

      assert CastleHelper.perform(board, :white, :kingside) == board
      assert CastleHelper.perform(board, :white, :queenside) == board
      assert CastleHelper.perform(board, :black, :kingside) == board
      assert CastleHelper.perform(board, :black, :kingside) == board
    end

    test "updates board state where it is possible" do
      board = Board.new
              |> Map.put(:f8, nil)
              |> Map.put(:g8, nil)

      new_board = CastleHelper.perform(board, :black, :kingside)

      refute board == new_board
      assert Map.get(new_board, :e8) == nil
      assert Map.get(new_board, :h8) == nil
      assert Map.get(new_board, :f8).rank == :rook
      assert Map.get(new_board, :g8).rank == :king
    end

    test "does nothing when it is impossible" do
      board = Board.new
              |> Map.update(:a1, nil, fn map -> %{map | has_moved: true} end)

      assert CastleHelper.perform(board, :white, :queenside) == board

    end
  end
end
