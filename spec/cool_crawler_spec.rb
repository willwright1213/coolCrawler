# frozen_string_literal: true

RSpec.describe CoolCrawler do
  it "has a version number" do
    expect(CoolCrawler::VERSION).not_to be nil
  end

  it "after crawling, all_links should contain " do
    crawler = CoolCrawler::CrawlerServer.new("https://people.scs.carleton.ca/~davidmckenney/fruitgraph/N-0.html", 10, 0.01)
    #crawler.set_callback(Proc.new{|page, links| p page})
    p crawler.callback
    crawler.run
    expect(crawler.sorted_visited.empty?).to be false
  end
end
