defmodule Mix.Tasks.Database.Uninstall do
  use Mix.Task
  use ConsadoleAggregator.Database

  @shortdoc "Uninstall Database"

  def run(_) do
    Amnesia.start

    ConsadoleAggregator.Database.destroy!

    Amnesia.stop
    Amnesia.Schema.destroy
  end
end
