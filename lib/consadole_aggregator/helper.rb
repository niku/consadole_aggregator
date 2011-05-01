module ConsadoleAggregator
  class Helper
    def self.concat text, opt=Hash.new('')
      base = "#{text} #{opt[:url]} #{opt[:hashtag]}".squeeze(' ').rstrip
      if base.size > 140
        over_size = base.size - 140
        concat(omit(text, over_size), opt)
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
