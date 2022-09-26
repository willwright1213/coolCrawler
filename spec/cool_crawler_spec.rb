# frozen_string_literal: true

RSpec.describe CoolCrawler do
  it "has a version number" do
    expect(CoolCrawler::VERSION).not_to be nil
  end

  it "after initialization, unvisited links must not be empty" do
    crawler = CoolCrawler.new('https://www.w3schools.com/tags/tag_a.asp')
    expect().not_to be nil
  end
end
