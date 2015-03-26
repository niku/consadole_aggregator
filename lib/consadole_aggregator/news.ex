defmodule ConsadoleAggregator.News do
  @moduledoc """
  News of Consadole Sapporo
  """

  @type t :: %__MODULE__{uri: URI.t, title: String.t}
  defstruct uri: %URI{}, title: ""

  @spec fetch(URI.t) :: {:ok, String.t} | {:error, String.t}
  def fetch(uri) do
    case HTTPoison.get(uri) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> {:ok, body}
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} -> {:error, "status_code: #{status_code}, body: #{body}"}
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
    end
  end

  @spec parse(String.t, :rss, any) :: [News.t]
  def parse(doc, :rss, _) do
    {:ok, feed, _} = FeederEx.parse(doc)
    Enum.map feed.entries, fn entry ->
      %__MODULE__{uri: URI.parse(entry.link), title: entry.title}
    end
  end

  @spec parse(String.t, :html, ParseConfig.t) :: [News.t]
  def parse(doc, :html, parse_config) do
    tree = :mochiweb_html.parse(doc)
    x = :mochiweb_xpath.execute(String.to_char_list(parse_config.xpath), tree)
    y = Enum.map x, parse_config.parser
    z = Enum.filter y, parse_config.filter
    Enum.map z, fn {uri, title} -> %__MODULE__{uri: uri, title: title} end
  end
end
