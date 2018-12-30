defmodule ExChecker.MoveCompletionHelperTest do
  use ExUnit.Case, async: true

  alias ExChecker.{Game, Move, MoveCompletionHelper}

  describe "complete_move/2" do
    test "returns the move unchanged for a castle" do
      game = Game.new
      move = %Move{castle: :queenside}
      assert MoveCompletionHelper.complete_move(game, move) == move
    end

    test "returns a completed move given a game context" do
      game = Game.new
      move = %Move{piece: :pawn, color: :white, to: :e4}
      move = MoveCompletionHelper.complete_move(game, move)
      assert move.from == :e2
    end
  end
end
