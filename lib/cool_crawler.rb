# frozen_string_literal: true

require_relative "coolCrawler/version"
require 'async'
require 'async/http/internet'
require 'async/barrier'
require 'nokogiri'

# Module Controller
module CoolCrawler
  class Error < StandardError; end

  # This is the class that handles the queue and async requests
  class CrawlerPool

    def initialize(start, max_connections, delay)
      @uri = URI(start)
      @site = "#{uri.scheme}://#{uri.host}"
      @max_connections = max_connections
      @delay = delay
      visited[uri.path] = 1
      queue << uri.path
    end

    attr_reader :max_connections, :uri, :delay, :callback, :site

    def set_callback(proc)
      @callback=proc
    end

    def run
      until queue.empty?
        send_crawlers
        sleep(delay)
      end
    end

    def after(page, links)
      callback.call(page, links) unless callback.nil?
    end

    def send_crawlers
      pages = []
      pages << queue.pop until queue.empty? || pages.size >= max_connections
      Async do
        internet = Async::HTTP::Internet.new
        barrier = Async::Barrier.new

        pages.each do |page|
          barrier.async do
            response = internet.get URI.join(@site, page).to_s
            links = gather_links_uri(response.read, URI.join(uri, page))
            after(page, links)
            links.each do |link|
              enqueue(link)
              add_to_visited(link)
            end
          end
        end
        barrier.wait
      ensure
        internet&.close
      end
    end

    def gather_links_uri(body, page)
      links = []
      doc = Nokogiri::HTML(body)
      doc.xpath("//a").each do |a|
        next if a["href"].nil?
        uri_a = URI(a["href"].strip.split('#')[0].sub(/\\|(\s+$)/, ""))
        begin
          links << URI.join(page, uri_a).path if (uri_a.host == uri.host || uri_a.host.nil?) && uri_a.path
        rescue
          # do nothing
        end
      end
      links
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
end
