# frozen_string_literal: true

require_relative "coolCrawler/version"
require "Nokogiri"
require "net/http"
require "open-uri"
require "uri"
# Module Controller
module CoolCrawler

  def constructRegexp(string)
    reg = ""
    string.each_char do |c|
      case c
      when "*"
        reg += "."
      when "."
        reg += "\."
      else
        reg += c
      end
    end
    Regexp.new(reg)
  end

  class Error < StandardError; end

  # Main Crawler Class
  class Crawler
    include CoolCrawler
    def initialize(root, thread_count, grace)
      @uri = URI(root)
      @root_path = @uri.path
      @website = "#{@uri.scheme}://#{@uri.host}"
      @disallows = disallows_regex
      @queue = []
      @visited = {}
      @queue << @uri.path # root is part of the pages to crawl
      start do |node|
        puts node
      end
      p all_links
    end

    def queue
      @queue
    end

    def http
      @http ||= Net::HTTP.new(@uri.host)
    end

    def start
      until queue.empty?
        p self.next
      end
    end

    def empty?
      @queue.empty?
    end

    def unvisited?(path)
      !@visited.include?(path)
    end

    def visited?(path)
      @visited.include?(path)
    end

    def root_path_include?(url_string)
      URI(url_string).path.start_with?(@root_path)
    end

    # to be redefined by the user if needed.Called after links have been scrapped and added to queue.
    def after_queue(current_page, links) end

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

    def gather_links_uri(doc, current)
      links = []
      doc.xpath("//a").each do |a|
        next if a['href'].nil?
        uri_a = URI(a['href'])
        links << URI.join(current, uri_a).path if (uri_a.host == @uri.host || uri_a.host.nil?) && uri_a.path
      end
      links
    end

    def get_body(uri)
      http.read_timeout = 5
      http.max_retries = 5
      res = http.get(uri.path)
      res.body
    end

    def enqueue(path)
      return if @visited.include?(path)
      queue << path
    end
    
    def add_to_queue(path)
      # return if visited?(path)
      current = URI.join(@website, path)
      doc = Nokogiri::HTML(get_body(current))
      links = gather_links_uri(doc, current).each do |link_uri|
        full_url = URI.join(@website, URI(path).path, link_uri)
        enqueue(full_url.path)
        add_to_visited(full_url.path)
      end
      [path, links]
    end

    def visit(path)
      return add_to_queue(path)
    end

    def next
      return visit(@queue.pop)
    end

    def scan_robots
      disallows = []
      begin
        URI.parse("#{@website}/robots.txt").open do |f|
          is_target = false
          f.each_line do |line|
            pair = line.split
            next if pair.size < 2

            disallows << pair[1] if is_target && pair[0].downcase == "disallow:"
            is_target = (pair[0].downcase == "user-agent:" && pair[1] == "RubyCrawler" || pair[1] == "*")
          end
        end
      rescue OpenURI::HTTPError
        disallows
      end
      disallows
    end

    # Scans the robots.txt file if available and return an array of regexp for all disallows
    def disallows_regex
      disallows_regex = Regexp.new("javascript:")
      scan_robots.each do |disallow|
        disallows_regex = Regexp.union(disallows_regex, constructRegexp(disallow))
      end
      disallows_regex
    end
  end
end
