# frozen_string_literal: true

require_relative "coolCrawler/version"
require "Nokogiri"
require "net/http"
require "open-uri"
require "uri"
# Module Controller
module CoolCrawler
  class Error < StandardError; end

  # Main Crawler Class
  class Crawler
    include CoolCrawler
    def initialize(root)
      @uri = URI(root)
      @website = "#{@uri.scheme}://#{@uri.host}"
      @queue = []
      @visited = { @uri.path => 1 }
      @queue << @uri.path # root is part of the pages to crawl
    end

    attr_reader :queue, :visted, :uri, :website

    def http
      @http ||= Net::HTTP.new(@uri.host)
    end

    def start
      return unless block_given?

      yield(self.next) until queue.empty?
    end

    def unvisited?(path)
      !@visited.include?(path)
    end

    def visited?(path)
      @visited.include?(path)
    end

    def add_to_visited(path)
      if visited?(path)
        @visited[path] += 1
      else
        @visited[path] = 1
      end
    end

    def all_links
      @visited.sort_by { |_k, v| v }
    end

    private

    def gather_links_uri(doc)
      doc.xpath("//a").each do |a|
        next if a["href"].nil?

        uri_a = URI(a["href"])
        yield URI.join(@current, uri_a).path if (uri_a.host == @uri.host || uri_a.host.nil?) && uri_a.path
      end
    end

    def get_body(uri)
      http.read_timeout = 5
      http.max_retries = 5
      res = http.get(uri.path)
      res.body
    end

    def enqueue(path)
      queue << path unless @visited.include?(path)
    end

    # Gathers the a['href'] links on a page and enqueues them
    def add_to_queue(path)
      links = []
      @current = URI.join(@website, path)
      doc = Nokogiri::HTML(get_body(@current))
      gather_links_uri(doc) do |link_uri|
        enqueue(link_uri)
        add_to_visited(link_uri)
        links << link_uri
      end
      [path, links]
    end

    def visit(path)
      add_to_queue(path)
    end

    def next
      visit(@queue.pop)
    end
  end
end
