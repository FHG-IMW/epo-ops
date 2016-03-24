require 'test_helper'

module Epo
  class RegisterTest < Minitest::Test
    def setup
      VCR.insert_cassette('epo_register', allow_playback_repeats: true)
    end

    def teardown
      VCR.eject_cassette
    end

    def test_raw_search_works
      query = EpoOps::SearchQueryBuilder.build(nil, Date.new(2016, 2, 3), 1, 100)
      response = EpoOps::Register.raw_search(query)
      assert response
      assert_instance_of Array, response
      response.each do |res|
        assert_instance_of EpoOps::Register::SearchEntry, res
      end
    end

    def test_raw_search_with_ipc_class
      query = EpoOps::SearchQueryBuilder.build('A', Date.new(2016, 2, 3), 1, 2)
      response = EpoOps::Register.raw_search(query)
      response.each do |res|
        assert_instance_of EpoOps::Register::SearchEntry, res
      end
    end

    def test_biblio
      appl_ref = EpoOps::Register::Reference.new('EP', '99203729', '20160203')
      publ_ref = EpoOps::Register::Reference.new('EP', '10000000', '20160203')
      entry = EpoOps::Register::SearchEntry.new(publ_ref, appl_ref, ['A'])
      doc = EpoOps::Register.biblio(entry)
      assert_instance_of EpoOps::BibliographicDocument, doc
      assert_instance_of Hash, doc.raw
      assert doc.title
      refute_empty doc.classifications
      refute_empty doc.agents
      refute_empty doc.applicants
      assert doc.status
      assert doc.latest_update
      assert_instance_of Hash, doc.priority_date
      refute_empty doc.publication_references
      assert doc.effective_date
      (doc.agents + doc.applicants).each do |addr|
        assert addr.name
        assert addr.address1
        assert addr.occurred_on
      end
    end

    def test_published_patent_counts
      cts = EpoOps::Register.published_patents_counts(nil, Date.new(2016, 2, 3))
      assert_equal 2859, cts
    end

    def test_retrieving_of_bibliographic_entries_works
      assert EpoOps::Register.raw_biblio('EP1000000', type = 'publication')
      assert EpoOps::Register.raw_biblio('EP99203729')
    end

    def test_biblio_returns_parsed_document
      doc = EpoOps::Register.raw_biblio('EP99203729')
      assert_instance_of EpoOps::BibliographicDocument, doc
      assert_instance_of Hash, doc.raw
      assert doc.title
      refute_empty doc.classifications
      refute_empty doc.agents
      refute_empty doc.applicants
      assert doc.status
      assert doc.latest_update
      assert_instance_of Hash, doc.priority_date
      refute_empty doc.publication_references
      assert doc.effective_date
      (doc.agents + doc.applicants).each do |addr|
        assert addr.name
        assert addr.address1
        assert addr.occurred_on
      end
    end

    def test_queries_are_split
      qrys = EpoOps::Register.split_by_size_limits('A', Date.new(2015, 2, 2), 301)
      assert_equal ['q=pd=20150202 and ic=A&Range=1-100',
                    'q=pd=20150202 and ic=A&Range=101-200',
                    'q=pd=20150202 and ic=A&Range=201-300',
                    'q=pd=20150202 and ic=A&Range=301-301'], qrys
    end

    def test_patent_counts_per_ipc_class
      counts = EpoOps::Register.patent_counts_per_ipc_class(Date.new(2016, 2, 3))
      actual = { 'A' => 531,
                 'B' => 650,
                 'C' => 556,
                 'D' => 50,
                 'E' => 102,
                 'F' => 389,
                 'G' => 658,
                 'H' => 742 }
      assert_equal actual, counts
    end

    # .search

    def test_404_leads_to_empty_result
      exception = ->(_a, _b) { fail EpoOps::Error::NotFound }
      EpoOps::Client.stub :request, exception do
        assert_equal [], EpoOps::Register.search(nil, Date.new(2016, 03, 01))
      end
    end
  end
end
