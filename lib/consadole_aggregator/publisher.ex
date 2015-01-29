defmodule ConsadoleAggregator.Publisher do
  use GenServer

  def start_link(handlers) do
    {:ok, event_manager} = GenEvent.start_link
    Enum.each(handlers, &GenEvent.add_handler(event_manager, &1, []))
    GenServer.start_link(__MODULE__, event_manager, name: __MODULE__)
  end

  def notify(message) do
    GenServer.call(__MODULE__, {:notify, message})
  end

  def handle_call({:notify, message}, _from, event_manager) do
    {:reply, GenEvent.sync_notify(event_manager, message), event_manager}
  end
end
