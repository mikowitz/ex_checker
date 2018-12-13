defprotocol ExChecker.Unicode do
  @fallback_to_any true
  def to_unicode(x)
end

defimpl ExChecker.Unicode, for: Any do
  def to_unicode(_), do: "_"
end
