defmodule ConsadoleAggregator.SourceTest do
  use ExUnit.Case, async: true

  test "parse from dict" do
    assert ConsadoleAggregator.Source.parse(name: "foo", uri: "bar") == %ConsadoleAggregator.Source{name: "foo", uri: "bar"}
  end
end
