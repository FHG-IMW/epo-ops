require 'test_helper'
require 'epo/ops/register'

class Epo::RegisterTest < Minitest::Test
  def setup
    VCR.insert_cassette('epo_register', allow_playback_repeats: true, record: :new_episodes)
  end

  def teardown
    VCR.eject_cassette
  end

  def test_search_works
    assert Epo::Ops::Register.search('foo')
    # TODO: continue :)
  end
end
