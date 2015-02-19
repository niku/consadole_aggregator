defmodule ConsadoleAggregator.TwitterHandler do
  use GenEvent

  def handle_event(%ConsadoleAggregator.News{} = news, _parent) do
    twitter_string = ConsadoleAggregator.Twitter.to_twitter_string(news)
    IO.puts "twit: #{twitter_string}"
    {:ok, news}
  end
end
