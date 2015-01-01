defmodule ConsadoleAggregator.SourceTest do
  use ExUnit.Case, async: true

  test "parse from dict" do
    name = "foo"
    uri = "http://example.com/"
    assert ConsadoleAggregator.Source.parse(name: name, uri: uri) ==
      %ConsadoleAggregator.Source{name: name, uri: URI.parse(uri)}
  end
end
