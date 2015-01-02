defmodule ConsadoleAggregator.News do
  @moduledoc """
  News of Consadole Sapporo
  """

  @spec fetch(URI.t) :: {:ok, String.t} | {:error, String.t}
  def fetch(uri) do
    case HTTPoison.get(uri) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> {:ok, body}
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} -> {:error, "status_code: #{status_code}, body: #{body}"}
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
    end
  end
end
