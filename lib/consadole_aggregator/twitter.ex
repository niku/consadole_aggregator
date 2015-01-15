defmodule ConsadoleAggregator.Twitter do
  @moduledoc """
  Utils for twitter
  """

  @twitter_hashtag "#consadole"
  @twitter_length_limit 140
  # https://dev.twitter.com/rest/reference/get/help/configuration
  @twitter_short_url_length 22
  @twitter_short_url_length_https 23

  @spec url_length(URI.t) :: non_neg_integer
  def url_length(%URI{scheme: "http"}), do: @twitter_short_url_length
  def url_length(%URI{scheme: "https"}), do: @twitter_short_url_length_https

  @spec to_twitter_string(ConsadoleAggregator.News.t) :: String.t
  def to_twitter_string(news = %ConsadoleAggregator.News{}) do
    %{title: title, uri: uri} = news
    Enum.join([title, to_string(uri), @twitter_hashtag], " ")
  end

  @spec snip(String.t, URI.t) :: String.t
  def snip(text, uri) do
    # "text url hashtag"
    #      ^   ^
    # So, space length = 2
    space_length = 2
    occupied_length = url_length(uri) + String.length(@twitter_hashtag) + space_length
    title_length = @twitter_length_limit - occupied_length
    String.slice(text, 0, title_length)
  end
end
