require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'epo/ops'

require 'webmock/minitest'
require "minitest/unit"
require 'minitest/autorun'
require 'vcr'
require 'mocha/mini_test'

# configure OAuth credentials
# make sure not to upload your real credentials, and token. Check your newly created
# VCR records.

Epo::Ops.configure do |config|
  config.consumer_key = 'Foo'
  config.consumer_secret =  'Bar'
end
# VCR
VCR.configure do |c|
  c.cassette_library_dir = 'test/vcr_cassettes'
  c.hook_into :webmock
end
