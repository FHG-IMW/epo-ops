require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'epo_ops'

require 'minitest/autorun'
require 'vcr'
require 'mocha/mini_test'

# configure OAuth credentials
# make sure not to upload your real credentials, and token. Check your newly created
# VCR records.
EpoOps.configure do |config|
  config.authentication = :oauth
  config.consumer_key = 'Foo'
  config.consumer_secret = 'Bar'
end

# VCR
VCR.configure do |c|
  c.cassette_library_dir = 'test/vcr_cassettes'
  c.hook_into :webmock
  c.default_cassette_options = {allow_playback_repeats: true}
end


class Minitest::Test
  def load_patent_application_data(name)
    data = YAML.load File.read("test/test_data/#{name.to_s}.yaml")

    EpoOps::Util.dig data, %w(world_patent_data register_search register_documents register_document)
  end

end
