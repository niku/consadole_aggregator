defmodule ConsadoleAggregator.TwitterTest do
  use ExUnit.Case, async: true

  import ConsadoleAggregator.Twitter, only: [url_length: 1]

  test "22 returned if given URI with http schema" do
    assert url_length(URI.parse("http://example.com/foo")) == 22
  end

  test "23 returned if given URI with https schema" do
    assert url_length(URI.parse("https://example.com/foo")) == 23
  end
end
