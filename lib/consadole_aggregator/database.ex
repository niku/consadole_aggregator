use Amnesia

defdatabase ConsadoleAggregator.Database do
  deftable Content, [{:id, autoincrement}, :uri, :title], type: :ordered_set, index: [:uri, :title] do
    @type t :: %__MODULE__{id: non_neg_integer, uri: URI.t, title: String.t}

    @spec unread?(ConsadoleAggregator.News.t) :: News.t | nil
    def unread?(news = %ConsadoleAggregator.News{}) do
      matched_in_db =  Amnesia.transaction do: __MODULE__.match(Map.from_struct(news))
      if is_nil(matched_in_db), do: news, else: nil
    end
  end
end
