module EpoOps
  module Factories
    # Parses the patent application data from EPO Ops into an PatentApplication object
    class PatentApplicationFactory
      class << self

        # @param raw_data [Hash] raw application data as retrieved from Epo Ops
        # @return [EpoOps::PatentApplication] PatentApplication filled with parsed data
        def build(raw_data)
          factory = new(raw_data)

          EpoOps::PatentApplication.new(
            factory.application_number,

            raw_data: raw_data,
            title: factory.title,
            status: factory.status,
            agents: factory.agents,
            applicants: factory.applicants,
            inventors: factory.inventors,
            classifications: factory.classifications,
            priority_claims: factory.priority_claims,
            publication_references: factory.publication_references,
            effective_date: factory.effective_date
          )
        end
      end

      attr_reader :raw_data

      def initialize(raw_data)
        @raw_data = raw_data
      end

      # @return [String] Application Number
      # @see EpoOps::PatentApplication#application_nr
      def application_number
        document_id = EpoOps::Util.flat_dig raw_data, data_path('application_reference', 'document_id')
        document_id = document_id.first if document_id.is_a?(Array)

        "#{document_id['country']}#{document_id['doc_number']}"
      end

      # @return [Hash] List of titles in different languages
      # @see EpoOps::PatentApplication#title
      def title
        titles = EpoOps::Util.flat_dig raw_data, data_path('invention_title')
        titles.inject({}) do |hash, title|
          hash[title['lang']] = title['__content__'] if title.is_a? Hash
          hash
        end
      end

      # @return [Array] List of {EpoOps::NameAndAddress}
      # @see EpoOps::PatentApplication#agents
      def agents
        EpoOps::Util.flat_dig(raw_data, data_path('parties', 'agents', 'agent', 'addressbook')).map do |agent|
          EpoOps::Factories::NameAndAddressFactory.build(agent)
        end
      end

      # @return [Array] List of {EpoOps::NameAndAddress}
      # @see EpoOps::PatentApplication#applicants
      def applicants
        EpoOps::Util.flat_dig(raw_data, data_path('parties', 'applicants', 'applicant', 'addressbook')).map do |applicant|
          EpoOps::Factories::NameAndAddressFactory.build(applicant)
        end
      end

      # @return [Array] List of {EpoOps::NameAndAddress}
      # @see EpoOps::PatentApplication#inventors
      def inventors
        EpoOps::Util.flat_dig(raw_data, data_path('parties', 'inventors', 'inventor', 'addressbook')).map do |inventor|
          EpoOps::Factories::NameAndAddressFactory.build(inventor)
        end
      end

      # @return [Array] List of IPC classes
      # @see EpoOps::PatentApplication#classifications
      def classifications
        EpoOps::Util.dig(raw_data, data_path('classifications_ipcr', 'classification_ipcr', 'text')).split(",").map(&:strip)
      end

      # @return [String] Application status as described by EPO
      # @see EpoOps::PatentApplication#status
      def status
        EpoOps::Util.dig raw_data, data_path('status')
      end

      # @return [Array] Hashes of priority claims
      # @see EpoOps::PatentApplication#priority_claims
      def priority_claims
        EpoOps::Util.flat_dig raw_data, data_path('priority_claims','priority_claim')
      end

      # @return [Array]
      # @see EpoOps::PatentApplication#publication_references
      def publication_references
        EpoOps::Util.flat_dig raw_data, data_path('publication_reference', 'document_id')
      end

      # @return [Date]
      # @see EpoOps::PatentApplication#effective_date
      def effective_date
        dates = EpoOps::Util.flat_dig raw_data, data_path('dates_rights_effective', 'request_for_examination')
        dates.first.nil? ? nil : dates.first['date']
      end

      private
      def data_path(*path)
        %w[bibliographic_data] + path
      end
    end
  end
end
