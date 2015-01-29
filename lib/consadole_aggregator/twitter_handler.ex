defmodule ConsadoleAggregator.TwitterHandler do
  use GenEvent

  def handle_event(event, _parent) do
    IO.puts "twit: #{inspect event}"
    {:ok, event}
  end
end
