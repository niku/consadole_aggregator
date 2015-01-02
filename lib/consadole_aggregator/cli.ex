defmodule ConsadoleAggregator.CLI do
  @moduledoc """
  Handle the command line parsing and dispatch to various functions.
  """

  @type runner :: :help | :news

  def run(argv) do
    parse_args(argv)
  end

  @doc """
  `argv` can be -h or --help, which returns :help.

  Otherwise it is a type of aggregation.

  Return a atom of `:news`, or `:help` if help was given
  """
  @spec parse_args([String.t]) :: runner
  def parse_args(argv) do
    parse = OptionParser.parse(argv,
                               switches: [help: :boolean],
                               aliases: [h: :help])
    case parse do
      {[help: true], _, _} -> :help
      {_, ["news"], _ } -> :news
      _ -> :help
    end
  end
end
