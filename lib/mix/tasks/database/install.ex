defmodule Mix.Tasks.Database.Install do
  use Mix.Task
  use ConsadoleAggregator.Database

  @shortdoc "Install Database"

  def run(_) do
    Amnesia.Schema.create
    Amnesia.start

    ConsadoleAggregator.Database.create!(disk: [node])
    ConsadoleAggregator.Database.wait

    Amnesia.stop
  end
end
