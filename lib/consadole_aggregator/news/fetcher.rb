require 'net/http'

module ConsadoleAggregator::News
  module Fetcher
    INPUT_ENCODING  = Encoding::UTF_8
    OUTPUT_ENCODING = Encoding::UTF_8

    def initialize name, logger
      @name = name
      @logger = logger.tap { |l| l.progname = "#{name}-#{self.class.name}" }
    end

    def invoke path, input_encoding: INPUT_ENCODING, output_encoding: OUTPUT_ENCODING
      doc = fetch_resource(path)
      doc.force_encoding(input_encoding)
      doc.encode(output_encoding).tap { |o|
        @logger.info { "success #{@name}" }
      }
    rescue
      @logger.warn { "failure #{$!}" }
      ''
    end

    def fetch_resource path
      # Implement here
    end
  end

  class HTTPFetcher
    include Fetcher

    def canonicalize_path path
      case path
      when String; URI.parse(path)
      when URI; path
      end
    end

    def fetch_resource path
      canonicalized_path = canonicalize_path(path)
      Net::HTTP.get(canonicalized_path)
    end
  end
end
