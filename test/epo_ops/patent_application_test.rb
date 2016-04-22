require 'test_helper'
require 'yaml'

module Epo
  module Ops
    class PatentApplicationTest < Minitest::Test
      def test_find_patent_application_by_id
        VCR.use_cassette('patent_application_requests') do
          patent = EpoOps::PatentApplication.find('EP99203729')
          assert patent.is_a? EpoOps::PatentApplication
          assert_equal 'EP99203729', patent.application_nr
        end
      end

      def test_search_patent_applications
        VCR.use_cassette('patent_application_requests') do
          search = EpoOps::PatentApplication.search("Range=1-2&q=pd=20160120")

          assert search.is_a? EpoOps::RegisterSearchResult
          assert_equal 8965, search.count
          assert_equal 2, search.patents.count

          assert_equal 'EP15474002', search.patents.first.application_nr
        end
      end

      def test_return_null_result_if_there_are_no_results
        VCR.use_cassette('patent_application_requests') do
          search = EpoOps::PatentApplication.search("Range=1-2&q=pd=20160121")

          assert search.is_a? EpoOps::RegisterSearchResult::NullResult
        end
      end

      def test_title_can_be_retrived_in_different_languages
        titles = {
          'en' => 'My Title',
          'de' => 'Mein Titel'
        }

        application = EpoOps::PatentApplication.new("123",title: titles)

        assert_equal titles['en'], application.title
        assert_equal titles['de'], application.title('de')
        assert_equal nil, application.title('sv')
      end

      def test_last_update_should_find_the_latest_date_in_the_change_gazette_num_fields
        raw_data = load_patent_application_data('epo_singleclassification_text')
        patent_application = EpoOps::PatentApplication.new('EP123', raw_data: raw_data)
        assert_equal(Date.commercial(2015, 27), patent_application.latest_update)
      end

      def test_url_generation
        application = EpoOps::PatentApplication.new("EP123",{})
        assert_equal 'https://ops.epo.org/3.1/rest-services/register/application/epodoc/EP123', application.url
      end

      def test_fetching_data
        VCR.use_cassette('patent_application_requests') do
          patent = EpoOps::PatentApplication.new('EP99203729')
          patent.fetch
          assert_equal "Apparatus for manufacturing green bricks for the brick manufacturing industry", patent.title
          assert patent.raw_data.is_a?(Hash)
        end
      end

      def test_raise_error_for_fetch_without_application_number
        patent = EpoOps::PatentApplication.new(nil)
        assert_raises StandardError do
          patent.fetch
        end
      end
    end
  end
end
