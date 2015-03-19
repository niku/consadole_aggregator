defmodule ConsadoleAggregator.TwitterHandler do
  use GenEvent

  def init(_args) do
    ExTwitter.configure(
      consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
      consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET"),
      access_token: System.get_env("TWITTER_ACCESS_TOKEN"),
      access_token_secret: System.get_env("TWITTER_ACCESS_SECRET")
    )
    {:ok, []}
  end

  def handle_event(%ConsadoleAggregator.News{} = news, _parent) do
    ConsadoleAggregator.Twitter.to_twitter_string(news) |> ExTwitter.update
    {:ok, news}
  end
end
