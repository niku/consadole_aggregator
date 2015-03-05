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
end
