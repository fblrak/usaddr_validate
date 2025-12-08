require "bundler/setup"
require "usaddr_validate"
require "webmock/rspec"
require "vcr"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    UsaddrValidate.reset_configuration
  end
end

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.filter_sensitive_data('[CLIENT_ID]') { ENV['USPS_CLIENT_ID'] }
  config.filter_sensitive_data('[CLIENT_SECRET]') { ENV['USPS_CLIENT_SECRET'] }
  config.filter_sensitive_data('[ACCESS_TOKEN]') { |interaction|
    if interaction.response.body.include?('access_token')
      JSON.parse(interaction.response.body)['access_token'] rescue nil
    end
  }
end
