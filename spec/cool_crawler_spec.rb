# frozen_string_literal: true

RSpec.describe CoolCrawler do
  it "has a version number" do
    expect(CoolCrawler::VERSION).not_to be nil
  end

  it "after crawling, all_links should contain " do
    crawler = CoolCrawler::CrawlerServer.new("https://people.scs.carleton.ca/~davidmckenney/fruitgraph/N-0.html", 5, 0.1)
    crawler.start { |node| p node }
    expect(crawler.all_links.empty?).to be false
  end
end
