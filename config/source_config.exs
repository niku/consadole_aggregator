use Mix.Config

config :consadole_aggregator, :source, [
           [
               name: "nikkansports",
               uri: "http://www.nikkansports.com/rss/soccer/jleague/consadole.rdf"
           ],
           [
               name: "hochiyomiuri",
               uri: "http://hochi.yomiuri.co.jp/soccer/jleague/index.htm"
           ]
       ]
