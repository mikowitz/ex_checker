defmodule ExChecker.Board do
  @moduledoc """
  Models a chess board and the pieces on it.
  """

  @ranks '12345678'
  @files 'abcdefgh'
  @squares for x <- @files, do: for y <- @ranks, do: String.to_atom(to_string([x, y]))
  defstruct Enum.map(List.flatten(@squares), fn sq -> {sq, nil} end)

  alias __MODULE__
  alias ExChecker.{Helpers, Piece}

  def new(config \\ starting_configuration()) do
    Enum.reduce(config, %__MODULE__{}, fn {square, piece}, board ->
      insert_at(board, square, piece)
    end)
  end

  def move(board, move), do: move(board, move.from, move.to)

  def move(board, nil, nil), do: board
  def move(board, from, to) when is_bitstring(from) do
    move(board, String.to_atom(from), to)
  end
  def move(board, from, to) when is_bitstring(to) do
    move(board, from, String.to_atom(to))
  end
  def move(board, from, to) when is_atom(from) and is_atom(to) do
    case Map.get(board, from) do
      nil -> {:error, board, :no_piece_to_move}
      piece = %{color: color} -> do_move_piece(board, piece, from, to, color)
    end
  end

  defp do_move_piece(board, piece, from, to, color) do
    case Map.get(board, to) do
      %ExChecker.Piece{color: ^color} -> {:error, board, :invalid_move}
      _ ->
        case is_valid_move(board, piece, from, to) do
          false -> {:error, board, :invalid_move}
          true ->
            {board, piece} = remove(board, from)
            piece = %{piece | has_moved: true}
            insert_at(board, to, piece)
        end
    end
  end

  def can_kingside_castle(board, :white) do
    do_can_kingside_castle(board, [:e1, :f1, :g1, :h1], :white)
  end
  def can_kingside_castle(board, :black) do
    do_can_kingside_castle(board, [:e8, :f8, :g8, :h8], :black)
  end

  def do_can_kingside_castle(board, squares, color) do
    case Enum.map(squares, &Map.get(board, &1)) do
      [
        %{rank: :king, color: ^color, has_moved: false},
        nil, nil,
        %{rank: :rook, color: ^color, has_moved: false}
      ] -> true
      _ -> false
    end
  end

  def kingside_castle(board, :white) do
    case can_kingside_castle(board, :white) do
      true ->
        board
        |> Map.put(:e1, nil)
        |> Map.put(:f1, %Piece{rank: :rook, color: :white, has_moved: true})
        |> Map.put(:g1, %Piece{rank: :king, color: :white, has_moved: true})
        |> Map.put(:h1, nil)
      false -> board
    end
  end
  def kingside_castle(board, :black) do
    case can_kingside_castle(board, :black) do
      true ->
        board
        |> Map.put(:e8, nil)
        |> Map.put(:f8, %Piece{rank: :rook, color: :black, has_moved: true})
        |> Map.put(:g8, %Piece{rank: :king, color: :black, has_moved: true})
        |> Map.put(:h8, nil)
      false -> board
    end
  end

  def can_queenside_castle(board, :white) do
    do_can_queenside_castle(board, [:a1, :b1, :c1, :d1, :e1], :white)
  end
  def can_queenside_castle(board, :black) do
    do_can_queenside_castle(board, [:a8, :b8, :c8, :d8, :e8], :black)
  end

  def do_can_queenside_castle(board, squares, color) do
    case Enum.map(squares, &Map.get(board, &1)) do
      [
        %{rank: :rook, color: ^color, has_moved: false},
        nil, nil, nil,
        %{rank: :king, color: ^color, has_moved: false}
      ] -> true
      _ -> false
    end
  end

  def queenside_castle(board, :white) do
    case can_queenside_castle(board, :white) do
      true ->
        board
        |> Map.put(:a1, nil)
        |> Map.put(:b1, nil)
        |> Map.put(:c1, %Piece{rank: :king, color: :white, has_moved: true})
        |> Map.put(:d1, %Piece{rank: :rook, color: :white, has_moved: true})
        |> Map.put(:e1, nil)
      false -> board
    end
  end
  def queenside_castle(board, :black) do
    case can_queenside_castle(board, :black) do
      true ->
        board
        |> Map.put(:a8, nil)
        |> Map.put(:b8, nil)
        |> Map.put(:c8, %Piece{rank: :king, color: :black, has_moved: true})
        |> Map.put(:d8, %Piece{rank: :rook, color: :black, has_moved: true})
        |> Map.put(:e8, nil)
      false -> board
    end
  end

  def all_pieces(board) do
    keys()
    |> Enum.map(fn key ->
      case Map.get(board, key) do
        nil -> []
        piece -> {key, piece}
      end
    end)
    |> List.flatten
  end

  def is_valid_move(board, piece, from, to) do
    to in valid_moves(piece, from, board)
  end

  def is_valid_en_passant_move(board, piece, from, to) do
    to in valid_en_passant_moves(piece, from, board)
  end

  defp insert_at(board, key, piece) do
    Map.put(board, key, piece)
  end

  defp remove(board, key) do
    piece = Map.get(board, key)
    new_board = Map.put(board, key, nil)
    {new_board, piece}
  end

  def possible_en_passant_moves_to(board, to) when is_bitstring(to) do
    possible_en_passant_moves_to(board, String.to_atom(to))
  end
  def possible_en_passant_moves_to(board, to) do
    board
    |> all_pieces
    |> Enum.map(fn {k, piece} ->
      cond do
        k == to -> []
        piece.rank != :pawn -> []
        true -> check_valid_en_passant_move(board, piece, k, to)
      end
    end) |> List.flatten
  end

  def check_valid_en_passant_move(board, piece, k, to) do
    case is_valid_en_passant_move(board, piece, k, to) do
      true -> {k, piece}
      false -> []
    end
  end

  def possible_moves_to(board, to) do
    board
    |> all_pieces()
    |> Enum.map(fn {k, piece} ->
      case k == to_atom(to) do
        true -> []
        false -> check_valid_move(board, piece, k, to)
      end
    end)
    |> List.flatten
  end

  def check_valid_move(board, piece, k, to) do
    case is_valid_move(board, piece, k, to_atom(to)) do
      true -> {k, piece}
      false -> []
    end
  end

  def valid_en_passant_moves(piece, from, board) do
    [x, y] = to_charlist(from)
    piece
    |> ExChecker.Piece.possible_moves
    |> Enum.map(fn moves ->
      Enum.reduce_while(moves, [], fn
        {dx, dy}, acc ->
          handle_regular_move({x, y}, {dx, dy}, board, piece, acc)
        {dx, dy, :capture}, acc ->
          handle_regular_move({x, y}, {dx, dy}, board, piece, acc)
      end)
    end)
    |> List.flatten
  end

  def valid_moves(piece, from, board) do
    [x, y] = to_charlist(from)
    piece
    |> ExChecker.Piece.possible_moves
    |> Enum.map(fn moves ->
      Enum.reduce_while(moves, [], fn
        {dx, dy}, acc ->
          handle_regular_move({x, y}, {dx, dy}, board, piece, acc)
        {dx, dy, :capture}, acc ->
          handle_capture_move({x, y}, {dx, dy}, board, piece, acc)
      end)
    end)
    |> List.flatten
  end

  def keys, do: @squares |> List.flatten

  defp handle_in_bounds_move(board, to_atom, piece, acc, is_capture) do
    case Map.get(board, to_atom) do
      nil ->
        case is_capture do
          true -> {:halt, acc}
          false -> {:cont, [to_atom|acc]}
        end
      target_piece ->
        case target_piece.color == piece.color do
          true -> {:halt, acc}
          false -> {:halt, [to_atom|acc]}
        end
    end
  end

  defp handle_any_move({x, y}, {dx, dy}, board, piece, acc, is_capture) do
    to = [nx, ny] = [x + dx, y + dy]
    to_atom = Helpers.to_atom(to)
    case nx < ?a || nx > ?h || ny < ?1 || ny > ?8 do
      true -> {:halt, acc}
      false -> handle_in_bounds_move(board, to_atom, piece, acc, is_capture)
    end
  end

  defp handle_capture_move(coord, delta, board, piece, acc) do
    handle_any_move(coord, delta, board, piece, acc, true)
  end

  defp handle_regular_move(coord, delta, board, piece, acc) do
    handle_any_move(coord, delta, board, piece, acc, false)
  end

  defp find_en_passant_moves_for(board, move) do
    board
    |> possible_en_passant_moves_to(move.to)
    |> filter_moves_by_origin(move)
  end

  defp find_moves_for(board, move) do
    board
    |> possible_moves_to(move.to)
    |> filter_moves_by_origin(move)
  end

  defp filter_moves_by_origin(possible_moves, move) do
    Enum.filter(possible_moves, fn {k, piece} ->
      piece.color == move.color && piece.rank == move.piece &&
        (k |> to_string |> String.match?(Regex.compile!(to_string(move.from))))
    end)
  end

  defp do_complete_en_passant_move(board, move) do
    {from, %{rank: :pawn}} = board
                             |>find_en_passant_moves_for(move)
                             |> List.first
    %{move | from: from, en_passant: true}
  end

  defp do_complete_regular_move(board, move) do
    {from, _piece} = board
                     |> find_moves_for(move)
                     |> List.first
    %{move | from: from}
  end

  def complete_move(board, _color, move = %{piece: :pawn}, ep_square) do
    case to_string(move.to) == to_string(ep_square) do
      true -> do_complete_en_passant_move(board, move)
      false -> do_complete_regular_move(board, move)
    end
  end
  def complete_move(_board, _, move = %{original: ""}, _), do: move
  def complete_move(_board, _, move = %{castle: :kingside}, _), do: move
  def complete_move(_board, _, move = %{castle: :queenside}, _), do: move
  def complete_move(board, _, move, _), do: do_complete_regular_move(board, move)

  def perform_move(board, _color, move) do
    case move do
      %{castle: :kingside} -> Board.kingside_castle(board, move.color)
      %{castle: :queenside} -> Board.queenside_castle(board, move.color)
      %{from: from, to: to, color: color, en_passant: true} ->
        existing_pawn_location = ExChecker.Game.en_passant_square(to, color)
        pawn = Map.get(board, from)
        board
        |> Map.put(existing_pawn_location, nil)
        |> Map.put(to_atom(to), pawn)
        |> Map.put(to_atom(from), nil)
      _ -> Board.move(board, move)
    end
  end

  def inspect(board) do
    board |> ExChecker.Unicode.board |> IO.puts
    board
  end

  defp to_atom(a) when is_atom(a), do: a
  defp to_atom(x), do: x |> to_string |> String.to_atom

  defp starting_configuration do
    [
      a1: Piece.rook(:white), b1: Piece.knight(:white), c1: Piece.bishop(:white), d1: Piece.queen(:white),
      e1: Piece.king(:white), f1: Piece.bishop(:white), g1: Piece.knight(:white), h1: Piece.rook(:white),
      a2: Piece.pawn(:white), b2: Piece.pawn(:white), c2: Piece.pawn(:white), d2: Piece.pawn(:white),
      e2: Piece.pawn(:white), f2: Piece.pawn(:white), g2: Piece.pawn(:white), h2: Piece.pawn(:white),
      a8: Piece.rook(:black), b8: Piece.knight(:black), c8: Piece.bishop(:black), d8: Piece.queen(:black),
      e8: Piece.king(:black), f8: Piece.bishop(:black), g8: Piece.knight(:black), h8: Piece.rook(:black),
      a7: Piece.pawn(:black), b7: Piece.pawn(:black), c7: Piece.pawn(:black), d7: Piece.pawn(:black),
      e7: Piece.pawn(:black), f7: Piece.pawn(:black), g7: Piece.pawn(:black), h7: Piece.pawn(:black)
    ]
  end
end
