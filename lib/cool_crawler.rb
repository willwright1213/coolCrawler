# frozen_string_literal: true

require_relative "coolCrawler/version"
require 'Nokogiri'
require 'open-uri'
require 'uri'

module CoolCrawler

  public
  def constructRegexp(string)
    reg = ""
    string.each_char do |c|
      if c == '*'
        reg += '.'
      elsif c == '.'
        reg += '\.'
      else
        reg += c
      end
    end
    return Regexp.new(reg)
  end

  class Error < StandardError; end
  class Crawler
    include CoolCrawler
    def initialize(root)
      uri = URI(root)
      @host = uri.host
      @website = uri.scheme + "://"+ @host
      @visited = [root]
      @disallow = getDisallow
      @visited.push(uri.path)
      @unvisited = Array.new
      add_to_queue(uri)
      puts @unvisited
    end
    def unvisited
      return @unvisited
    end

    private
    
    def add_to_queue(uri)
      Nokogiri::HTML(URI.open(uri)).xpath("//a").each do |a|
        ignore = false
        @disallow.each {|regex|
          if regex.match?(a['href'])
            ignore = true
          end
        }
        unless ignore
          link_uri = URI(a['href'])
          if link_uri.host == @host || link_uri.host.nil?
            @unvisited.push(link_uri.path)
          end
        end
      end
    end

    # Scans the robots.txt file if available and populates the @disallow list with the mentionned regex
    def getDisallow
      disallow_list = [Regexp.new("javascript:")]
      URI.open(@website+"/robots.txt") { |f|
        is_target = false
        f.each_line { |line|
          pair = line.split
          if pair.size == 2
            if is_target
              if pair[0].downcase == "disallow:"
                disallow_list.push(constructRegexp(pair[1]))
                puts disallow_list
              end
            end
            if pair[0].downcase == "user-agent:"
              if constructRegexp(pair[1]).match?("RubyCrawler")
                is_target = true
              else
                is_target = false
              end
            end
          end
        }
      }
      return disallow_list
    end
  end
end
