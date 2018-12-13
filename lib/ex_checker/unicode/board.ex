defimpl ExChecker.Unicode, for: ExChecker.Board do
  alias ExChecker.Helpers

  def to_unicode(board = %ExChecker.Board{}) do
    Helpers.ordered_squares()
    |> Enum.map(fn squares ->
      squares
      |> Enum.map(fn square ->
        board
        |> Map.get(square)
        |> ExChecker.Unicode.to_unicode()
      end)
      |> Enum.join(" ")
    end)
    |> Enum.join("\n")
  end
end

