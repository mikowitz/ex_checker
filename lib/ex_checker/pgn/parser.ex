defmodule ExChecker.PGN.Parser do
  @moduledoc """
  Code for parsing a .pgn file
  """

  @turn_regex ~r/(?<white>[^\s]+)\s?(?<black>[^\s]+)?(?<comment>.*)?$/
  @result_regex ~r/(1|0|1\/2)-(1|0|1\/2)/

  def parse!(filename) do
    filename
    |> File.read!
    |> String.split("\n", trim: true)
    |> Enum.reject(&Regex.match?(~r/^\s*$/, &1))
    |> split_metadata()
  end

  defp split_metadata(parsed_pgn) do
    %{true => metadata, false => game} = Enum.group_by(parsed_pgn, &String.starts_with?(&1, "["))
    %{metadata: parse_metadata(metadata), game: parse_turns(game)}
  end

  defp parse_metadata(metadata) do
    Enum.into(metadata, %{}, fn datum ->
      %{"key" => k, "value" => v } = Regex.named_captures(~r/^\[(?<key>[^\s]+)\s+\"(?<value>.*)\"\]/, datum)
      {k, v}
    end)
  end

  defp parse_turns(game) when is_list(game) do
    game
    |> Enum.join(" ")
    |> parse_turns()
  end

  defp parse_turns(game) do
    game
    |> String.replace(@result_regex, "")
    |> String.trim
    |> String.split(~r/\d+\./, trim: true)
    |> Enum.map(&Regex.named_captures(@turn_regex, &1, [capture: [:white, :black, :comment]]))
    |> Enum.with_index(1)
    |> Enum.into(%{}, fn {map, i} ->
      {
        i,
        [
          parse_move(:white, map["white"]),
          parse_move(:black, map["black"])
        ]
      }
    end)
  end

  def parse_move(_, ""), do: %ExChecker.Move{original: ""}
  def parse_move(color, str = "O-O"), do: %ExChecker.Move{castle: :kingside, color: color, original: str}
  def parse_move(color, str = "O-O-O"), do: %ExChecker.Move{castle: :queenside, color: color, original: str}

  def parse_move(color, str = "K" <> rest), do: parse_move(:king, color, rest, str)
  def parse_move(color, str = "Q" <> rest), do: parse_move(:queen, color, rest, str)
  def parse_move(color, str = "R" <> rest), do: parse_move(:rook, color, rest, str)
  def parse_move(color, str = "N" <> rest), do: parse_move(:knight, color, rest, str)
  def parse_move(color, str = "B" <> rest), do: parse_move(:bishop, color, rest, str)
  def parse_move(color, str = move), do: parse_move(:pawn, color, move, str)

  def parse_move(piece, color, move, original) do
    captures = Regex.named_captures(~r/^((?<from>[^x]+)?(?<capture>x?))(?<to>[^+#]{2})(?<check>[+#])?$/, move)
    captures = Enum.map(captures, fn {k, v} -> {String.to_atom(k), v} end)
    %{struct(ExChecker.Move, captures) | piece: piece, color: color, original: original}
  end
end
