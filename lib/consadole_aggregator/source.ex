defmodule ConsadoleAggregator.Source do
  @moduledoc """
  Source of the Consadole-Sapporo information.
"""

  defmodule ParseConfig do
    @type t :: %__MODULE__{xpath: String.t, parser: Function.t, filter: Function.t}
    defstruct xpath: "", parser: nil, filter: nil

    @spec parse(Dict.t) :: t
    def parse([xpath: xpath, parser: parser, filter: filter]) do
      %__MODULE__{xpath: xpath, parser: parser, filter: filter}
    end
  end

  @type t :: %__MODULE__{name: String.t, uri: URI.t, type: atom, parse_config: ParseConfig.t | nil}
  defstruct name: "", uri: %URI{}, type: :undefined, parse_config: nil

  @spec parse(Dict.t) :: t

  def parse([name: name, uri: uri, type: :rss]) do
    %__MODULE__{name: name, uri: URI.parse(uri), type: :rss}
  end

  def parse([name: name, uri: uri, type: :html, parse_config: parse_config]) do
    %__MODULE__{name: name, uri: URI.parse(uri), type: :html, parse_config: ParseConfig.parse(parse_config)}
  end

  def sources do
    [
        %__MODULE__{
                name: "official rss",
                uri: "http://www.consadole-sapporo.jp/news/atom.xml",
                type: :rss
            },
        %__MODULE__{
                name: "nikkansports",
                uri: "http://www.nikkansports.com/rss/soccer/jleague/consadole.rdf",
                type: :rss
            },
        %__MODULE__{
                name: "official photes on the top page",
                uri: "http://www.consadole-sapporo.jp/",
                type: :html,
                parse_config: %__MODULE__.ParseConfig{
                                  xpath: ~s<//div[@class="wrapper"]//li>,
                                parser: fn item ->
                                  title = :mochiweb_xpath.execute('/li/@title', item) |> hd
                                  image = :mochiweb_xpath.execute('//img/@src', item) |> hd
                                  href = :mochiweb_xpath.execute('//a/@href', item) |> hd
                                  {URI.parse(href), Enum.join([title, image], " ") |> String.strip}
                                end,
                                filter: fn {_uri, _title} -> true end
                              }
            },
        %__MODULE__{
                name: "Next Home Game",
                uri: "http://www.consadole-sapporo.jp/",
                type: :html,
                parse_config: %__MODULE__.ParseConfig{
                                  xpath: ~s{//div[@id="next-homegame"]},
                                parser: fn item ->
                                  [target, now] = :mochiweb_xpath.execute('//ul//li/text()', item)
                                  [date, time_and_place, opponent | _] = :mochiweb_xpath.execute('//dd/p/text()', item) |> Enum.map(&String.strip/1)
                                  text = "次のホームゲームは #{date} #{time_and_place} #{opponent}，チケット販売数 現在:#{now}/目標:#{target}"
                                  {URI.parse("http://www.consadole-sapporo.jp/lp/"), text}
                                end,
                                filter: fn {_uri, _title} -> true end
                              }
            },
        %__MODULE__{
                name: "hochiyomiuri",
                uri: "http://www.hochi.co.jp/soccer/national/",
                type: :html,
                parse_config: %__MODULE__.ParseConfig{
                                  xpath: ~s{//ul[@class="article_text"]/li/a[not(@class)]},
                                parser: fn item ->
                                  {"a", [{"href", uri}], [title|_]} = item
                                  {URI.parse(uri), String.strip(title)}
                                end,
                                filter: fn {_uri, title} ->
                                  String.contains?(title, ["札幌"])
                                end
                              }
            },
        %__MODULE__{
                name: "kouta's-check",
                uri: "http://www.hochi.co.jp/soccer/feature/TO000258",
                type: :html,
                parse_config: %__MODULE__.ParseConfig{
                                  xpath: ~s{//div[@id="article1"]//span[@class="ar_title"]/a | //ul[@class="article_text"]/li/a},
                                parser: fn item ->
                                  uri = elem(item, 1) |> Enum.find(fn {k, _v} -> k === "href" end) |> elem(1)
                                  title = elem(item, 2) |> hd
                                  {URI.parse(uri), String.strip(title)}
                                end,
                                filter: fn {_uri, _title} -> true end
                              }
            },

        %__MODULE__{
                name: "hokkaido-np",
                uri: "http://dd.hokkaido-np.co.jp/sports/soccer/consadole/",
                type: :html,
                parse_config: %__MODULE__.ParseConfig{
                                  xpath: ~s{//ul[@class="newsList"]/li/a},
                                parser: fn item ->
                                  uri = elem(item, 1) |> Enum.find(fn {k, _v} -> k === "href" end) |> elem(1)
                                  title = elem(item, 2) |> hd
                                  {URI.parse("http://dd.hokkaido-np.co.jp" <> uri), String.strip(title)}
                                end,
                                filter: fn {_uri, _title} -> true end
                              }
            },
        %__MODULE__{
                name: "consa-club",
                uri: "http://dd.hokkaido-np.co.jp/cont/consa-club/",
                type: :html,
                parse_config: %__MODULE__.ParseConfig{
                                  xpath: ~s{//ul[@class="newsList"]/li/a},
                                parser: fn item ->
                                  uri = elem(item, 1) |> Enum.find(fn {k, _v} -> k === "href" end) |> elem(1)
                                  title = elem(item, 2) |> hd
                                  {URI.parse("http://dd.hokkaido-np.co.jp" <> uri), String.strip(title)}
                                end,
                                filter: fn {_uri, _title} -> true end
                              }
            },
        %__MODULE__{
                name: "consa-burn",
                uri: "http://dd.hokkaido-np.co.jp/cont/consa-burn/",
                type: :html,
                parse_config: %__MODULE__.ParseConfig{
                                  xpath: ~s{//ul[@class="newsList"]/li/a},
                                parser: fn item ->
                                  uri = elem(item, 1) |> Enum.find(fn {k, _v} -> k === "href" end) |> elem(1)
                                  title = elem(item, 2) |> hd
                                  {URI.parse("http://dd.hokkaido-np.co.jp" <> uri), String.strip(title)}
                                end,
                                filter: fn {_uri, _title} -> true end
                              }
            },
        %__MODULE__{
                name: "gekisaka",
                uri: "http://web.gekisaka.jp/news/category?category=domestic",
                type: :html,
                parse_config: %__MODULE__.ParseConfig{
                                  xpath: ~s{//div[@class="post-title"]/a},
                                parser: fn item ->
                                  uri = :mochiweb_xpath.execute('/a/@href', item) |> hd
                                  title = :mochiweb_xpath.execute('/a/text()', item) |> hd
                                  {URI.parse(uri), title}
                                end,
                                filter: fn {_uri, title} -> String.contains?(title, "札幌") end
                              }
            }
    ]
  end
end
