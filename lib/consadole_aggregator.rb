require "consadole_aggregator/version"
require 'consadole_aggregator/loggable'
require 'consadole_aggregator/helper.rb'
require 'consadole_aggregator/live.rb'
require 'consadole_aggregator/news.rb'

require 'logger'
require 'fileutils'

module ConsadoleAggregator
  class << self
    DEFAULT_ROOT_DIR = File.expand_path('~/.consadole_aggregator')
    DEFAULT_LOG_NAME = 'consadole_aggregator.log'

    def root_dir
      return @root_dir if @root_dir
      FileUtils.mkdir_p DEFAULT_ROOT_DIR unless File.exist? DEFAULT_ROOT_DIR
      @root_dir = DEFAULT_ROOT_DIR
    end

    def root_dir= root_dir
      FileUtil.mkdir_p root_dir unless File.exist? root_dir
      @logger &&= Logger.new(File.join(root_dir, DEFAULT_LOG_NAME))
      @root_dir = root_dir
    end

    def logger
      @logger ||= Logger.new(File.join(root_dir, DEFAULT_LOG_NAME))
    end
  end
end
