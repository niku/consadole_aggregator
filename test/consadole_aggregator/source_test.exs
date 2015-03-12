defmodule ConsadoleAggregator.SourceTest do
  use ExUnit.Case, async: true

  test "parse from dict" do
    name = "foo"
    uri = "http://example.com/"
    type = :rss
    assert ConsadoleAggregator.Source.parse(name: name, uri: uri, type: type) ==
      %ConsadoleAggregator.Source{name: name, uri: URI.parse(uri), type: type}
  end
end
