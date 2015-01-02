defmodule ConsadoleAggregator.CLITest do
  use ExUnit.Case, async: true

  import ConsadoleAggregator.CLI, only: [parse_args: 1]

  test ":help returned by option parsing with -h" do
    assert parse_args(["-h", "anything"]) == :help
  end

  test ":help returned by option parsing with --help" do
    assert parse_args(["--help", "anything"]) == :help
  end

  test ":news returned if `news` given" do
    assert parse_args(["news"]) == :news
  end
end
