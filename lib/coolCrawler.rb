# frozen_string_literal: true

require_relative "coolCrawler/version"

module CoolCrawler
  class Error < StandardError; end


  class CrawlerPool

    def initialize(threads, delay)
      @threads = threads
      @delay = delay
    end

  end

  class Crawler

    def initialize
    end

    # Can be override with 
    def after
    end

    def bfs
    end




  end

end
