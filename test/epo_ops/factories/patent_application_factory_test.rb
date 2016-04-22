require 'test_helper'

module EpoOps
  module Factories
    class PatentApplicationFactoryTest < Minitest::Test

      def test_building_a_new_patent_application
        data = load_patent_application_data :epo_singleclassification_text
        PatentApplication.expects(:new).with do |a,b|
          keys = [:raw_data, :title, :status, :agents, :applicants, :inventors, :classifications, :priority_claims, :publication_references, :effective_date]
[:raw_data, :title, :status, :agents, :applicants, :inventors, :classifications, :priority_claims, :publication_references, :effective_date]
          a == "EP14154144" && b.keys == keys
        end.once

        EpoOps::Factories::PatentApplicationFactory.build(data)
      end

      # application_number

      def test_application_number_extraction
        data = load_patent_application_data :epo_singleclassification_text
        factory = EpoOps::Factories::PatentApplicationFactory.new(data)

        assert_equal "EP14154144", factory.application_number
      end

      # title
      def test_title_extraction
        data = load_patent_application_data :epo_singleclassification_text
        factory = EpoOps::Factories::PatentApplicationFactory.new(data)

        titles = {
             'de' => 'Instantpulver für wässrige kosmetische und pharmazeutische Anwendungen',
             'fr' => 'Poudres instantanées pour applications cosmétiques et pharmaceutiques aqueuses',
             'en' => 'Instant powders for aqueous cosmetic and pharmaceutical applications'
        }

        assert_equal titles, factory.title
      end

      #agents

      def test_agents_returns_empty_list_when_no_agent_available
        data = load_patent_application_data :epo_no_agent
        factory = EpoOps::Factories::PatentApplicationFactory.new(data)
        assert_equal [], factory.agents
      end

      def test_extract_agents
        data = load_patent_application_data :epo_two_agent
        factory = EpoOps::Factories::PatentApplicationFactory.new(data)

        EpoOps::Factories::NameAndAddressFactory.expects(:build).with {|data| data.instance_of?(Hash)}.twice.returns(1,2)

        agents = factory.agents
        assert 2, agents.count
        assert [1,2], agents
      end

      # status
      def test_status_extraction
        data = load_patent_application_data :epo_singleclassification_text
        factory = EpoOps::Factories::PatentApplicationFactory.new(data)

        status = 'EXAMINATION REQUESTED'

        assert_equal status, factory.status
      end

      # priority_claims
      def test_priority_claims_extraction
        data = load_patent_application_data :epo_singleclassification_text
        factory = EpoOps::Factories::PatentApplicationFactory.new(data)

        assert_equal 2, factory.priority_claims.count
        assert_equal 'national', factory.priority_claims.first['kind']
      end


      # publication_references
      def test_publication_references_extraction
        data = load_patent_application_data :epo_singleclassification_text
        factory = EpoOps::Factories::PatentApplicationFactory.new(data)

        assert_equal 1, factory.publication_references.count
        assert_equal 'EP', factory.publication_references.first['country']
      end

      # classifications
      def test_classifications_should_be_a_list_of_strings
        data = load_patent_application_data :epo_singleclassification_text
        factory = EpoOps::Factories::PatentApplicationFactory.new(data)

        result = factory.classifications
        assert_kind_of Array, result
        refute_equal 1, result.length
        assert_kind_of String, result.first
      end

      #def test_url
      #  assert_equal 'https://ops.epo.org/3.1/rest-services/register/application/epodoc/EP14154144', @single_class.url
      #end
    end
  end
end
