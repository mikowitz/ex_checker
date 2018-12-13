defimpl ExChecker.Unicode, for: ExChecker.Piece do
  @unicode_list [
    white: [
      pawn: "♙",
      king: "♔",
      queen: "♕",
      rook: "♖",
      knight: "♘",
      bishop: "♗"
    ],
    black: [
      pawn: "♟",
      king: "♚",
      queen: "♛",
      rook: "♜",
      knight: "♞",
      bishop: "♝"
    ]
  ]

  def to_unicode(%ExChecker.Piece{color: color, rank: rank}) do
    get_in(@unicode_list, [color, rank])
  end
end
