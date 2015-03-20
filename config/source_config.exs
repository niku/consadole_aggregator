use Mix.Config

config :consadole_aggregator, :source, [
  [
      name: "official rss",
      uri: "http://www.consadole-sapporo.jp/news/atom.xml",
      type: :rss
  ],
  [
      name: "nikkansports",
      uri: "http://www.nikkansports.com/rss/soccer/jleague/consadole.rdf",
      type: :rss
  ],
  [
      name: "hochiyomiuri",
      uri: "http://www.hochi.co.jp/soccer/national/",
      type: :html,
      parse_config: [
        xpath: ~s{//ul[@class="article_text"]/li/a[not(@class)]},
        parser: fn item ->
          {"a", [{"href", uri}], [title|_]} = item
          {URI.parse(uri), String.strip(title)}
        end,
        filter: fn {_uri, title} ->
          String.contains?(title, ["札幌"])
        end
      ]
  ],
  [
      name: "kouta's-check",
      uri: "http://www.hochi.co.jp/soccer/feature/TO000258",
      type: :html,
      parse_config: [
        xpath: ~s{//div[@id="article1"]//span[@class="ar_title"]/a | //ul[@class="article_text"]/li/a},
        parser: fn item ->
          {"a", [{"href", uri}], [title|_]} = item
          {URI.parse(uri), String.strip(title)}
        end,
        filter: fn {_uri, _title} -> true end
      ]
  ],
  [
      name: "hokkaido-np",
      uri: "http://dd.hokkaido-np.co.jp/sports/soccer/consadole/",
      type: :html,
      parse_config: [
        xpath: ~s{//ul[@class="newsList"]/li/a},
        parser: fn item ->
          {"a", [{"href", uri}], [title|_]} = item
          {URI.parse("http://dd.hokkaido-np.co.jp" <> uri), String.strip(title)}
        end,
        filter: fn {_uri, _title} -> true end
      ]
  ],
  [
      name: "consa-club",
      uri: "http://dd.hokkaido-np.co.jp/cont/consa-club/",
      type: :html,
      parse_config: [
        xpath: ~s{//ul[@class="newsList"]/li/a},
        parser: fn item ->
          {"a", [{"href", uri}], [title|_]} = item
          {URI.parse("http://dd.hokkaido-np.co.jp" <> uri), String.strip(title)}
        end,
        filter: fn {_uri, _title} -> true end
      ]
  ],
  [
      name: "consa-burn",
      uri: "http://dd.hokkaido-np.co.jp/cont/consa-burn/",
      type: :html,
      parse_config: [
        xpath: ~s{//ul[@class="newsList"]/li/a},
        parser: fn item ->
          {"a", [{"href", uri}], [title|_]} = item
          {URI.parse("http://dd.hokkaido-np.co.jp" <> uri), String.strip(title)}
        end,
        filter: fn {_uri, _title} -> true end
      ]
  ]
]
