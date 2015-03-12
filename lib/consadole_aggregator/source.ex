defmodule ConsadoleAggregator.Source do
  @moduledoc """
  Source of the Consadole-Sapporo information.
"""

  @type t :: %__MODULE__{name: String.t, uri: URI.t, type: atom}
  defstruct name: "", uri: %URI{}, type: :undefined

  @spec parse(Dict.t) :: t
  def parse([name: name, uri: uri, type: type]), do: %__MODULE__{name: name, uri: URI.parse(uri), type: type}
end
