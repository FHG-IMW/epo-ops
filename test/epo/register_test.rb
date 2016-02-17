require 'test_helper'
require 'epo/ops/register'

class Epo::RegisterTest < Minitest::Test
  def setup
    VCR.insert_cassette('epo_register', allow_playback_repeats: true)
  end

  def teardown
    VCR.eject_cassette
  end

  def test_search_works
    query = Epo::Ops::SearchQueryBuilder.new.publication_date(2016, 2, 3).build
    response = Epo::Ops::Register.search(query)
    assert response
    assert_instance_of Hash, response
  end
end
