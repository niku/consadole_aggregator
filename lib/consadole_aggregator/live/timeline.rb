# -*- coding: utf-8 -*-
module ConsadoleAggregator::Live
  Timeline = Struct.new(:time, :post)
  class Timeline
    def self.parse line
      return nil if line.nil? || line.empty? || line =~ /(&lt;前半&gt;)|(&lt;後半&gt;)/
      Timeline.new(*line.split('　'))
    end
    def to_s
      ('%s %s'%[time, post]).squeeze.rstrip
    end
  end
end
