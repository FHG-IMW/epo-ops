require 'test_helper'
require 'yaml'

module Epo
  module Ops
    class BibliographicDocumentTest < Minitest::Test

      def setup
        single_classification_raw = YAML.load File.read('test/test_data/epo_singleclassification_text.yaml')
        multi_classification_raw = YAML.load File.read('test/test_data/epo_multiclassification_text.yaml')
        no_agent_raw = YAML.load File.read('test/test_data/epo_no_agent.yaml')
        two_agents_raw = YAML.load File.read('test/test_data/epo_two_agent.yaml')
        agent_5_address_raw = YAML.load File.read('test/test_data/epo_agent_with_5_address_fields.yaml')
        application_nr = Epo::Ops::Util.find_in_data(single_classification_raw, %w(world_patent_data register_search query __content__)).first.partition('=').last
        url = "https://ops.epo.org/3.1/rest-services/register/application/epodoc/#{application_nr}"
        @single_class = Epo::Ops::BibliographicDocument.new(url: url, raw: single_classification_raw)
        @multi_class = Epo::Ops::BibliographicDocument.new(url: url, raw: multi_classification_raw)
        @no_agent = Epo::Ops::BibliographicDocument.new(url: url, raw: no_agent_raw)
        @multi_agent = Epo::Ops::BibliographicDocument.new(url: url, raw: two_agents_raw)
        @agent_5_address = Epo::Ops::BibliographicDocument.new(url: url, raw: agent_5_address_raw)
      end

      def test_get_agents_can_retrieve_single_agent_as_element_in_array
        assert_equal 1, @single_class.agents.length
      end

      def test_title_should_be_automatically_extracted
        assert_equal 'Instant powders for aqueous cosmetic and pharmaceutical applications', @single_class.title
      end

      def test_agent_has_values_name_address1_address2_country
        agent = @single_class.agents.first
        assert agent.name
        assert agent.address1
        assert agent.address2
      end

      def test_agents_returns_empty_list_when_no_agent_available
        assert_equal [], @no_agent.agents
      end

      def test_agents_returns_list_of_agents_when_more_than_one_is_available
        refute_equal 1, @multi_agent.agents.length
        refute_equal 0, @multi_agent.agents.length
      end

      def test_classifications_should_be_a_list_of_strings
        result = @single_class.classifications
        assert_kind_of Array, result
        refute_equal 1, result.length
        assert_kind_of String, result.first
      end

      def test_applicants_should_be_found_and_have_fields_name_address1_address2_country_address3_5_should_be_not_null
        result = @single_class.applicants
        assert_kind_of Array, result
        applicant = result.first
        assert_equal 'Akzo Nobel Chemicals International B.V.', applicant.name
        assert_equal 'Stationsstraat 77', applicant.address1
        assert_equal '3811 MH  Amersfoort', applicant.address2
        assert_equal "", applicant.address3
        assert_equal "", applicant.address4
        assert_equal "", applicant.address5
      end

      def test_all_5_address_fields_should_be_readable
        result = @agent_5_address.agents
        assert_kind_of Array, result
        agent = result.first
        assert_equal 'Velperweg 76', agent.address1
        assert_equal '6824 BM Arnhem', agent.address2
        assert_equal 'address field 3', agent.address3
        assert_equal 'address field 4', agent.address4
        assert_equal 'address field 5', agent.address5
      end

      def test_multiple_applicants_should_be_found
        result = @multi_class.applicants
        assert result
        assert_equal 2, result.length
      end

      def test_last_update_should_find_the_latest_date_in_the_change_gazette_num_fields
        result = @single_class.latest_update
        assert_equal(Date.commercial(2015, 27), result)
      end

      def test_application_nr_should_work
        result = @single_class.application_nr
        assert_equal 'EP14154144', result
      end

      def test_cdsid_of_agent_should_be_read
        result = @agent_5_address.agents
        agent = result.first
        assert agent.cdsid
      end
    end
  end
end
