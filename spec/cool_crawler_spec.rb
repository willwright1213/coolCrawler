# frozen_string_literal: true

RSpec.describe CoolCrawler do
  it "has a version number" do
    expect(CoolCrawler::VERSION).not_to be nil
  end

  it "after initialization, unvisited links must not be empty" do
    crawler = CoolCrawler::Crawler.new("https://people.scs.carleton.ca/~davidmckenney/fruitgraph/N-0.html", 1, 0.05)
    expect(crawler.empty?).to be false
  end
end
