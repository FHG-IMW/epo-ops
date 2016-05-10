require 'test_helper'

module EpoOps
  class RegisterTest < Minitest::Test
    def setup
      VCR.insert_cassette('epo_register', allow_playback_repeats: true)
    end

    def teardown
      VCR.eject_cassette
    end

    def test_raw_search_works
      query = EpoOps::SearchQueryBuilder.build(nil, Date.new(2016, 2, 3), 1, 25)
      response = EpoOps::Register.raw_search(query)
      assert response
      assert_instance_of EpoOps::RegisterSearchResult, response
      assert_equal 25, response.patents.count
    end

    def test_raw_search_with_ipc_class
      query = EpoOps::SearchQueryBuilder.build('A', Date.new(2016, 2, 3), 1, 2)
      response = EpoOps::Register.raw_search(query)
      assert response
      assert_instance_of EpoOps::RegisterSearchResult, response
      assert_equal 2, response.patents.count
    end

    def test_published_patent_counts
      cts = EpoOps::Register.published_patents_counts(nil, Date.new(2016, 2, 3))
      assert_equal 2859, cts
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

    def test_404_leads_to_null_result
      exception = ->(_a, _b) { fail EpoOps::Error::NotFound }
      EpoOps::Client.stub :request, exception do
        query = EpoOps::SearchQueryBuilder.build(nil, Date.new(2016, 2, 3), 1, 25)
        assert_instance_of EpoOps::RegisterSearchResult::NullResult, EpoOps::Register.raw_search(query)
      end
    end
  end
end
