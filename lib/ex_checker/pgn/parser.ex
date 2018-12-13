defmodule ExChecker.PGN.Parser do
  @moduledoc """
  Code for parsing a .pgn file
  """

  @turn_regex ~r/(?<white>[^\s]+)\s?(?<black>[^\s]+)?(?<comment>.*)?$/
  @result_regex ~r/(1|0|1\/2)-(1|0|1\/2)/
  @move_regex ~r/^(?<rank>[KQRNB])?(?<from>[^x]+)?(?<capture>x?)(?<to>[^+#]{2})(?<check>[+#])?$/

  alias ExChecker.Helpers

  def parse!(filename) do
    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.reject(&Regex.match?(~r/^\s*$/, &1))
    |> split_metadata_and_moves()
  end

  ## PRIVATE

  defp split_metadata_and_moves(parsed_pgn) do
    %{true => metadata, false => game} = Enum.group_by(parsed_pgn, &String.starts_with?(&1, "["))
    %{metadata: parse_metadata(metadata), game: parse_turns(game)}
  end

  defp parse_metadata(metadata) do
    Enum.into(metadata, %{}, fn datum ->
      %{"key" => k, "value" => v} =
        Regex.named_captures(~r/^\[(?<key>[^\s]+)\s+\"(?<value>.*)\"\]/, datum)
      {k, v}
    end)
  end

  defp parse_turns(game) when is_list(game) do
    game |> Enum.join(" ") |> parse_turns()
  end

  defp parse_turns(game) do
    game
    |> String.replace(@result_regex, "")
    |> String.split(~r/\d+\./, trim: true)
    |> Enum.map(&Regex.named_captures(@turn_regex, &1, capture: [:white, :black, :comment]))
    |> Enum.map(fn map ->
      [
        parse_move(:white, map["white"]),
        parse_move(:black, map["black"])
      ]
    end)
  end

  def parse_move(_, ""), do: %ExChecker.Move{original: ""}
  def parse_move(color, str = "O-O"), do: %ExChecker.Move{castle: :kingside, color: color, original: str}
  def parse_move(color, str = "O-O-O"), do: %ExChecker.Move{castle: :queenside, color: color, original: str}
  def parse_move(color, move) do
    captures = Regex.named_captures(@move_regex, move)
    move_map = Enum.into(captures, %{color: color, original: move}, fn {k, v} ->
      {
        Helpers.to_atom(k),
        (if v == "", do: nil, else: v)
      }
    end)
    |> Map.put(:piece, piece_from(captures["rank"]))
    struct(ExChecker.Move, move_map)
  end

  defp piece_from("K"), do: :king
  defp piece_from("Q"), do: :queen
  defp piece_from("R"), do: :rook
  defp piece_from("B"), do: :bishop
  defp piece_from("N"), do: :knight
  defp piece_from(""), do: :pawn
  defp piece_from(nil), do: :pawn
end
