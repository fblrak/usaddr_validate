require_relative "lib/usaddr_validate/version"

Gem::Specification.new do |spec|
  spec.name        = "usaddr_validate"
  spec.version     = UsaddrValidate::VERSION
  spec.authors     = ["Michael Davie"]
  spec.email       = ["mike@backwardm.com"]
  spec.summary     = "USPS Address validation using the USPS Address 3.0 API because the old one is going offline."
  spec.description = "A gem for validating US addresses using the USPS Address 3.0 API"
  spec.homepage    = "https://github.com/backwardm/usaddr_validate"
  spec.license     = "MIT"

  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir["{lib}/**/*", "LICENSE.txt", "README.md", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "faraday-retry", "~> 2.0"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.0"
  spec.add_development_dependency "vcr", "~> 6.0"
end
