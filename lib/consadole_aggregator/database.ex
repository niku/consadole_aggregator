use Amnesia

defdatabase ConsadoleAggregator.Database do
  deftable Content, [{:id, autoincrement}, :uri, :title], type: :ordered_set, index: [:uri, :title] do
    @type t :: %__MODULE__{id: non_neg_integer, uri: URI.t, title: String.t}
  end
end
