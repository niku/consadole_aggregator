defmodule ConsadoleAggregator.Source do
  @moduledoc """
  Source of the Consadole-Sapporo information.
"""

  @type t :: %__MODULE__{name: String.t, uri: URI.t}
  defstruct name: "", uri: nil

  @spec parse(Dict.t) :: t
  def parse([name: name, uri: uri]), do: %__MODULE__{name: name, uri: uri}
end
