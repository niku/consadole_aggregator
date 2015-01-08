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
end
