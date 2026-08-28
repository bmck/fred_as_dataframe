require 'bundler/setup'
require 'fred_as_dataframe'
require 'vcr'
require 'webmock/rspec'
require 'rack'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.filter_sensitive_data('<FRED_API_KEY>') { ENV['FRED_API_KEY'] }
  config.filter_sensitive_data('<FRED_API_KEY>') { FredAsDataframe::Client.api_key }
  
  # Custom matcher that ignores query parameter order
  config.register_request_matcher :uri_without_param_order do |request_1, request_2|
    uri_1 = URI(request_1.uri)
    uri_2 = URI(request_2.uri)
    
    uri_1.scheme == uri_2.scheme &&
      uri_1.host == uri_2.host &&
      uri_1.path == uri_2.path &&
      Rack::Utils.parse_query(uri_1.query) == Rack::Utils.parse_query(uri_2.query)
  end
  
  config.default_cassette_options = {
    match_requests_on: [:method, :uri_without_param_order]
  }
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed

  config.before(:each) do
    FredAsDataframe::Client.api_key = nil
  end
end
