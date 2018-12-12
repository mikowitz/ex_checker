defmodule ExChecker.Helpers do
  @moduledoc """
  Helper functions shared across ExChecker.
  """
  def ordered_squares do
    for r <- '87654321', do: for f <- 'abcdefgh', do: [f, r] |> to_string |> to_atom
  end

  def to_atom(a) when is_atom(a), do: a
  def to_atom(x), do: x |> to_string |> String.to_atom

  def rank_file(square) do
    [tf, tr] = square |> to_string |> String.graphemes
    {tr, ""} = Integer.parse(tr)
    {tr, tf}
  end
end
