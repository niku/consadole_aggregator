module ConsadoleAggregator
  class Helper
    PLACE_HOLDER = '@'
    PLACE_HOLD_MATCHER = Regexp.compile("#{PLACE_HOLDER}{20}")

    def self.truncate_for_twitter text, opt={}
      url_place_holder = opt[:url] && PLACE_HOLDER*20 # twitter compress url to t.co as length 20 characters.
      base = "#{text} #{url_place_holder} #{opt[:hashtag]}".squeeze(' ').rstrip
      if base.size > 140
        over_size = base.size - 140
        self.truncate_for_twitter(omit(text, over_size), opt)
      else
        base.gsub(PLACE_HOLD_MATCHER) { opt[:url] } # revert place holder to url
      end
    end

    private
    def self.omit text, over_size
      truncated = text.slice(0...-over_size)
      truncated[-3..-1] = '...'
      truncated
    end
  end
end
