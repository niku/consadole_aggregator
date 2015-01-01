defmodule ConsadoleAggregator.Config do
  @moduledoc """
  A Config of the ConsadoleAggregator.
"""

  @spec source() :: [ConsadoleAggregator.Source.t]
  def source do
    conf = Application.get_env(:consadole_aggregator, :source)
    Enum.map(conf, &ConsadoleAggregator.Source.parse/1)
  end
end
