# -*- coding: utf-8 -*-
require 'consadole_aggregator/entry.rb'
require 'consadole_aggregator/live.rb'

module ConsadoleAggregator
  def self.truncate str, url=''
    if "#{str} #{url} #consadole".squeeze(' ').size > 140
      truncated_size = 140 - "... #{url} #consadole".squeeze(' ').size
      "#{str[0...truncated_size]}... #{url}".rstrip
    else
      "#{str} #{url}".rstrip
    end
  end
end
