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

    for source <- ConsadoleAggregator.Source.sources do
      {:ok, doc} = ConsadoleAggregator.News.fetch(source.uri)

      for news <- ConsadoleAggregator.News.parse(doc, source.type, source.parse_config),
      ConsadoleAggregator.Database.Content.unread?(news) do
        ConsadoleAggregator.Publisher.notify(news)
        ConsadoleAggregator.Database.Content.register(news)
      end
    end
  end

  defp start_link do
    ConsadoleAggregator.Publisher.start_link([
      ConsadoleAggregator.TwitterHandler,
      ConsadoleAggregator.StdoutHandler
    ])
  end
end
