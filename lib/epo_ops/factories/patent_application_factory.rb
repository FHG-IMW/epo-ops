module EpoOps
  module Factories
    class PatentApplicationFactory
      class << self
        def build(raw_data)
          factory = new(raw_data)

          Epo::PatentApplication.new(
            title: factory.title,
            status: factoy.status,
          )
        end
      end

      attr_reader :raw_data


      def initialize(raw_data)
        @raw_data = raw_data
      end

      def title
        titles = EpoOps::Util.flat_dig raw_data, data_path('invention_title')
        titles.inject({}) do |hash, title|
          hash[title['lang']] = title['__content__']
          hash
        end
      end

      def agents
        EpoOps::Util.flat_dig(raw_data, data_path('parties', 'agents', 'agent', 'addressbook')).map do |agent|
          EpoOps::Factories::NameAndAddressFactory.build(agent)
        end
      end

      def applicants
        EpoOps::Util.flat_dig(raw_data, data_path('parties', 'applicants', 'applicant', 'addressbook')).map do |applicant|
          EpoOps::Factories::NameAndAddressFactory.build(applicant)
        end
      end

      def inventors
        EpoOps::Util.flat_dig(raw_data, data_path('parties', 'inventors', 'inventor', 'addressbook')).map do |inventor|
          EpoOps::Factories::NameAndAddressFactory.build(inventor)
        end
      end

      def classifications
        EpoOps::Util.dig(raw_data, data_path('classifications_ipcr', 'classification_ipcr', 'text')).split(",").map(&:strip)
      end

      def status
        EpoOps::Util.dig raw_data, data_path('status')
      end

      def priority_claims
        EpoOps::Util.flat_dig raw_data, data_path('priority_claims','priority_claim')
      end

      def publication_references
        EpoOps::Util.flat_dig raw_data, data_path('publication_reference', 'document_id')
      end

      def effective_date
        dates = EpoOps::Util.flat_dig raw_data, data_path('dates_rights_effective', 'request_for_examination')
        dates.first.nil? ? nil : dates.first['date']
      end

      private
        def data_path(*path)
          %w(bibliographic_data) + path
        end

    end
  end
end