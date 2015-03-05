use Mix.Config

config :consadole_aggregator, :source, [
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
                   String.contains?(title, ["札幌", "宏太’Ｓチェック"])
                 end
               ]
           ]
       ]
