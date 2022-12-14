# CoolCrawler

Cool Crawler is a light weight crawler for the purpose of that one university assignment.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'coolCrawler'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install coolCrawler

## Usage



```ruby
    require 'cool_crawler'
    # create a set of 10 crawlers with a delay of 0.01 seconds between each group of crawl
    crawler = CoolCrawler::CrawlerServer.new("https://github.com", 10, 0.01)
    
    # set the callback function. This will be called everytime an individual crawler finishes its crawling. page is current path the crawler is on, links is an array
    # of all links found
    crawler.set_callback(Proc.new {|page, links| p page, links})

    # starts the crawl (ends when thare no more page in queue)
    crawler.run
    end
```

## TO-DO

### For version 0.1.x:    

* Implement method to scan and apply the rules of robots.txt 
* add a way to limit the number of links in the queue 
* Sleep period can be specified in the start block, but it would be good to have it supplied as configuration 
* Test and adapt for concurrency 

I will implement pageranking in 0.2.x   

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/coolCrawler. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/coolCrawler/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CoolCrawler project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/coolCrawler/blob/master/CODE_OF_CONDUCT.md).
