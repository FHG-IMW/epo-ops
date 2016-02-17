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
    query = Epo::Ops::SearchQueryBuilder.new.publication_date(2016, 2, 3).build
    response = Epo::Ops::Register.search(query)
    assert response
    assert_instance_of Array, response
    response.each do |res|
      assert_instance_of Epo::Ops::Register::SearchEntry, res
    end
  end

  def test_retrieving_of_bibliographic_entries_works
    assert Epo::Ops::Register.biblio("EP1000000", type="publication")
    assert Epo::Ops::Register.biblio("EP99203729")
  end

  def test_biblio_returns_parsed_document
    doc = Epo::Ops::Register.biblio("EP99203729")
    assert doc.title
    refute_empty doc.classifications
    refute_empty doc.agents
    refute_empty doc.applicants
    assert doc.status
    assert doc.latest_update
    assert_instance_of Hash, doc.priority_date
    refute_empty doc.publication_dates
    assert doc.effective_date
    (doc.agents + doc.applicants).each do |addr|
      assert addr.name
      assert addr.address1
      assert addr.last_occurred_on
    end
  end
end
