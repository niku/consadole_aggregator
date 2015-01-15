defmodule ConsadoleAggregator.TwitterTest do
  use ExUnit.Case, async: true

  import ConsadoleAggregator.Twitter, only: [url_length: 1, to_twitter_string: 1]

  test "22 returned if given URI with http schema" do
    assert url_length(URI.parse("http://example.com/foo")) == 22
  end

  test "23 returned if given URI with https schema" do
    assert url_length(URI.parse("https://example.com/foo")) == 23
  end

  test "\"title uri #consadole\" returned if gieven news" do
    assert to_twitter_string(%ConsadoleAggregator.News{uri: URI.parse("https://example.com/foo"), title: "タイトル"}) == "タイトル https://example.com/foo #consadole"
  end
end
