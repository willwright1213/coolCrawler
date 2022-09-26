# frozen_string_literal: true

RSpec.describe CoolCrawler do
  it "has a version number" do
    expect(CoolCrawler::VERSION).not_to be nil
  end

  it "after initialization, unvisited links must not be empty" do
    crawler = CoolCrawler::Crawler.new('https://www.w3schools.com/tags/tag_a.asp')
    expect(crawler.unvisited.size).not_to be 0
  end
end
