require 'logger'

module ConsadoleAggregator
  module Loggable
    ::Logger::Severity.constants.map(&:downcase).each do |name|
      # define [debug, error, fatal, info, unknown, warn]
      define_method(name) do |&block|
        @logger.__send__(name, &block) if @logger
      end
    end

    def logger= logger
      @logger = logger
    end
  end
end
