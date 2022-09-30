# frozen_string_literal: true

require_relative "coolCrawler/version"
require "Nokogiri"
require "net/http"
require 'async'
require 'async/http/internet'
# Module Controller
module CoolCrawler
  class Error < StandardError; end

  # This is the class that handles the queue and async requests
  class CrawlerServer

    def initialize(start, max_connections, delay)
      uri = URI(start)
      @site = "#{uri.scheme}://#{uri.host}"
      @max_connections = max_connections
      @delay = delay
      visted[uri.path] = 1
      queue << uri.path
    end

    def send_crawlers
      page_queue = []
      until queue.empty? || page_queue.size >= max_connections
        page_queue << queue.pop
      end
      Async do
        internet = Async::HTTP::Internet.new
        barrier = Async::Barrier.new

        page_queue.each do |page|
          barrier.async do 
            response = internet.get URI.join(@site, page).to_s
            p Crawler.new(response.read).gather_links_uri
          end
        end
        barrier.wait
      end
      internet&.close
    end

    def queue
      @queue ||= Queue.new
    end

    def visited
      @visited ||= {}
    end

    def visited?(path)
      visited.include?(path)
    end

    def add_to_visited(path)
      if visited?(path)
        visited[path] += 1
      else
        visited[path] = 1
      end
    end

    def sorted_visited
      visited.sort_by { |_k, v| v }
    end

    def enqueue(path)
      queue << path unless visited.include?(path)
    end

  end


  # This is the individual crawler
  class Crawler
    include CoolCrawler
    def initialize(current, response)
      @current = URI(current)
      @response = response
    end

    attr_reader :uri, :website

    private

    def gather_links_uri(doc)
      links = []
      doc = Nokogiri::HTML(response)
      doc.xpath("//a").each do |a|
        next if a["href"].nil?
        uri_a = URI(a["href"])
        links << URI.join(@current, uri_a).path if (uri_a.host == @uri.host || uri_a.host.nil?) && uri_a.path
      end
      links
    end
    
  end
end
