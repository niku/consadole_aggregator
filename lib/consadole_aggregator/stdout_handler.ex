defmodule ConsadoleAggregator.StdoutHandler do
  use GenEvent

  def handle_event(%ConsadoleAggregator.News{} = news, _parent) do
    IO.puts "stdout: #{inspect news}"
    {:ok, news}
  end
end
