defmodule ExChecker.BoardConfigurations do
  alias ExChecker.Piece

  def standard_configuration do
    [
      a1: Piece.wr,
      b1: Piece.wn,
      c1: Piece.wb,
      d1: Piece.wq,
      e1: Piece.wk,
      f1: Piece.wb,
      g1: Piece.wn,
      h1: Piece.wr,
      a2: Piece.wp,
      b2: Piece.wp,
      c2: Piece.wp,
      d2: Piece.wp,
      e2: Piece.wp,
      f2: Piece.wp,
      g2: Piece.wp,
      h2: Piece.wp,
      a8: Piece.br,
      b8: Piece.bn,
      c8: Piece.bb,
      d8: Piece.bq,
      e8: Piece.bk,
      f8: Piece.bb,
      g8: Piece.bn,
      h8: Piece.br,
      a7: Piece.bp,
      b7: Piece.bp,
      c7: Piece.bp,
      d7: Piece.bp,
      e7: Piece.bp,
      f7: Piece.bp,
      g7: Piece.bp,
      h7: Piece.bp
    ]
  end
end
