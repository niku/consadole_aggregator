defmodule ConsadoleAggregator.TwitterTest do
  use ExUnit.Case, async: true

  import ConsadoleAggregator.Twitter, only: [url_length: 1, to_twitter_string: 1, snip: 2]

  test "22 returned if given URI with http schema" do
    assert url_length(URI.parse("http://example.com/foo")) == 22
  end

  test "23 returned if given URI with https schema" do
    assert url_length(URI.parse("https://example.com/foo")) == 23
  end

  test "snip text if it is too long" do
    # "あ" * 140
    text = Stream.repeatedly(fn -> "あ" end) |> Enum.take(140) |> Enum.join
    uri = URI.parse("http://example.com/foo/bar/baz")
    # (space)    =>  1
    # short_url  => 22
    # (space)    =>  1
    # #consadole => 10
    #               34
    # 140 - 34 = 106
    assert String.length(snip(text, uri)) == 106
  end

  test "snip text if it is too long, and uri schema is https" do
    text = Stream.repeatedly(fn -> "あ" end) |> Enum.take(140) |> Enum.join
    uri = URI.parse("https://example.com/foo/bar/baz")
    assert String.length(snip(text, uri)) == 105
  end

  test "\"title uri #consadole\" returned if gieven news" do
    assert to_twitter_string(%ConsadoleAggregator.News{uri: URI.parse("https://example.com/foo"), title: "タイトル"}) == "タイトル https://example.com/foo #consadole"
  end
end
