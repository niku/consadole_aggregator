defmodule ConsadoleAggregator.ConfigTest do
  use ExUnit.Case, async: true

  test "load source from config" do
    assert Enum.count(ConsadoleAggregator.Config.source) > 0
  end
end
