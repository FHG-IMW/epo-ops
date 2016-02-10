$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'epo/ops'

require 'minitest/autorun'

# load OAuth credentials
require 'yaml'
config = YAML.load_file('epo_credentials.yml')
Epo::Ops.configure do |conf|
  conf.consumer_key = config.consumer_key
  conf.consumer_secret = config.consumer_secret
end
