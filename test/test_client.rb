# frozen_string_literal: true

require 'set'
require 'bundler/setup'
require_relative '../lib/fred_as_dataframe'

failures = []
failures << 'version' if FredAsDataframe::VERSION.to_s.empty?
client = FredAsDataframe::Client.new('UNRATE')
failures << 'instantiate' unless client.is_a?(FredAsDataframe::Client)
failures << 'fetch' unless client.respond_to?(:fetch)
failures << 'tag' unless client.tag == 'UNRATE'
failures << 'configure' unless FredAsDataframe::Client.respond_to?(:configure)

if failures.empty?
  puts 'test_client: ok'
else
  abort "test_client failed: #{failures.join(', ')}"
end
