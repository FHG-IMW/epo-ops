$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'epo/ops'

require 'webmock/minitest'
require 'minitest/autorun'
require 'vcr'

# load OAuth credentials
require 'yaml'
config = YAML.load_file(File.join(__dir__, 'epo_credentials.yml'))
Epo::Ops.configure do |conf|
  puts config
  conf.consumer_key = config["consumer_key"]
  conf.consumer_secret = config["consumer_secret"]
end

# VCR
VCR.configure do |c|
  c.cassette_library_dir = 'test/vcr_cassettes'
  c.hook_into :webmock
end
