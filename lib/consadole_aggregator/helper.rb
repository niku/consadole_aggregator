module ConsadoleAggregator
  class Helper
    def self.concat text, url='', hashtag=''
      base = "#{text} #{url} #{hashtag}".squeeze(' ').rstrip
      if base.size > 140
        over_size = base.size - 140
        concat(omit(text, over_size), url, hashtag)
      else
        base
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
