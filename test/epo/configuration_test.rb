require 'test_helper'

class TestConfiguration < Minitest::Test
  def test_setting_the_configuration_options
    Epo::Ops.configure do |conf|
      conf.consumer_key = 'foo'
      conf.consumer_secret = 'bar'
      conf.redis = { host: 'localhost' }
    end

    assert_equal 'foo', Epo::Ops.config.consumer_key
    assert_equal 'bar', Epo::Ops.config.consumer_secret
  end
end
