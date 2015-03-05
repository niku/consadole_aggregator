defmodule ConsadoleAggregator.Mixfile do
  use Mix.Project

  def project do
    [app: :consadole_aggregator,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps,
     dialyzer: dialyzer,
     escript: [main_module: ConsadoleAggregator.CLI]]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger,
                    :httpoison,
                    :amnesia]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [{:httpoison, "~> 0.5"},
     {:amnesia, github: "meh/amnesia"},
     {:mochiweb, github: "mochi/mochiweb", override: true},
     {:mochiweb_xpath, github: "retnuh/mochiweb_xpath"}]
  end

  defp dialyzer do
    [plt_add_apps: [:xmerl]]
  end
end
