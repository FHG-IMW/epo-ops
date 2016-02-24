require 'test_helper'
require 'epo/ops/register'

module Epo
  class RegisterTest < Minitest::Test
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
      assert Epo::Ops::Register.biblio('EP1000000', type = 'publication')
      assert Epo::Ops::Register.biblio('EP99203729')
    end

    def test_biblio_returns_parsed_document
      doc = Epo::Ops::Register.biblio('EP99203729')
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
        assert addr.last_occurred_on
      end
    end

    def test_all_queries_on_returns_proper_list_of_queries
      queries = Epo::Ops::Register::Bulk.all_queries(Date.new(2016, 02, 03))
      assert_equal 41, queries.length
      assert_equal ['search?q=pd=20160203 and ic=A&Range=1-100',
                    'search?q=pd=20160203 and ic=A&Range=101-200',
                    'search?q=pd=20160203 and ic=A&Range=201-300',
                    'search?q=pd=20160203 and ic=A&Range=301-400',
                    'search?q=pd=20160203 and ic=A&Range=401-500',
                    'search?q=pd=20160203 and ic=A&Range=501-531',
                    'search?q=pd=20160203 and ic=B&Range=1-100',
                    'search?q=pd=20160203 and ic=B&Range=101-200',
                    'search?q=pd=20160203 and ic=B&Range=201-300',
                    'search?q=pd=20160203 and ic=B&Range=301-400',
                    'search?q=pd=20160203 and ic=B&Range=401-500',
                    'search?q=pd=20160203 and ic=B&Range=501-600',
                    'search?q=pd=20160203 and ic=B&Range=601-650',
                    'search?q=pd=20160203 and ic=C&Range=1-100',
                    'search?q=pd=20160203 and ic=C&Range=101-200',
                    'search?q=pd=20160203 and ic=C&Range=201-300',
                    'search?q=pd=20160203 and ic=C&Range=301-400',
                    'search?q=pd=20160203 and ic=C&Range=401-500',
                    'search?q=pd=20160203 and ic=C&Range=501-556',
                    'search?q=pd=20160203 and ic=D&Range=1-50',
                    'search?q=pd=20160203 and ic=E&Range=1-100',
                    'search?q=pd=20160203 and ic=E&Range=101-102',
                    'search?q=pd=20160203 and ic=F&Range=1-100',
                    'search?q=pd=20160203 and ic=F&Range=101-200',
                    'search?q=pd=20160203 and ic=F&Range=201-300',
                    'search?q=pd=20160203 and ic=F&Range=301-389',
                    'search?q=pd=20160203 and ic=G&Range=1-100',
                    'search?q=pd=20160203 and ic=G&Range=101-200',
                    'search?q=pd=20160203 and ic=G&Range=201-300',
                    'search?q=pd=20160203 and ic=G&Range=301-400',
                    'search?q=pd=20160203 and ic=G&Range=401-500',
                    'search?q=pd=20160203 and ic=G&Range=501-600',
                    'search?q=pd=20160203 and ic=G&Range=601-658',
                    'search?q=pd=20160203 and ic=H&Range=1-100',
                    'search?q=pd=20160203 and ic=H&Range=101-200',
                    'search?q=pd=20160203 and ic=H&Range=201-300',
                    'search?q=pd=20160203 and ic=H&Range=301-400',
                    'search?q=pd=20160203 and ic=H&Range=401-500',
                    'search?q=pd=20160203 and ic=H&Range=501-600',
                    'search?q=pd=20160203 and ic=H&Range=601-700',
                    'search?q=pd=20160203 and ic=H&Range=701-742'], queries
    end
  end
end
