defmodule ConsadoleAggregator.CLI do
  @moduledoc """
  Handle the command line parsing and dispatch to various functions.
  """

  @type runner :: :help | :news

  def main(args) do
    args
    |> parse_args
    |> process
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

  @spec process(runner) :: any

  def process(:help) do
    IO.puts """
    usage: consadole_aggregator news
    """
    System.halt(0)
  end

  def process(:news) do
    start_link

    %{uri: uri} = Enum.find(ConsadoleAggregator.Config.source, &(%{name: "nikkansports"} = &1))
    {:ok, doc} = uri |> ConsadoleAggregator.News.fetch

    doc
    |> ConsadoleAggregator.News.parse_rss
    |> Enum.filter(&ConsadoleAggregator.Database.Content.unread?/1)
    |> Enum.map(&ConsadoleAggregator.Twitter.to_twitter_string/1)
    |> Enum.each(&ConsadoleAggregator.Publisher.notify/1)
    # |> Enum.each(&ConsadoleAggregator.Database.Content.register/1)
  end

  defp start_link do
    ConsadoleAggregator.Publisher.start_link([
      ConsadoleAggregator.TwitterHandler,
      ConsadoleAggregator.StdoutHandler
    ])
  end
end
