require 'test_helper'

module EpoOps
  module Factories
    class PatentApplicationFactoryTest < Minitest::Test

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


        pp factory.agents
        pp factory.applicants
        pp factory.inventors
        pp factory.classifications
      end
    end
  end
end
