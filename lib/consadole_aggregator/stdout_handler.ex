defmodule ConsadoleAggregator.StdoutHandler do
  use GenEvent

  def handle_event(event, _parent) do
    IO.puts "stdout: #{inspect event}"
    {:ok, event}
  end
end
