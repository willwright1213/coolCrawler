# frozen_string_literal: true

require_relative "lib/coolCrawler/version"

Gem::Specification.new do |spec|
  spec.name = "coolCrawler"
  spec.version = CoolCrawler::VERSION
  spec.authors = ["William Wright"]
  spec.email = ["williamwright3@cmail.carleton.ca"]

  spec.summary = "Simple Web Crawler"
  spec.homepage = "https://github.com/willwright1213/coolCrawler"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/willwright1213/coolCrawler"
  spec.metadata["changelog_uri"] = "https://github.com/willwright1213/coolCrawler/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_development_dependency "rspec", "~> 3.11"
  spec.add_dependency 'async-http'
  spec.add_dependency "nokogiri"
  spec.add_dependency "open-uri"
  spec.add_dependency "uri"
  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
