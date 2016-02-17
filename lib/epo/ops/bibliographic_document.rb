module Epo
  module Ops

    # Parses and simplifies the elements the EPO OPS returns for bibliographic
    # documents. Parsing is done lazily.
    # Some elements are not yet fully parsed but hashes returned instead.
    # Not all information available is parsed (e.g. inventors), if you need
    # more fields, add them here.
    class BibliographicDocument
      attr_reader :raw

      def initialize(raw)
        @raw = raw
      end

      def application_nr
        @application_nr || parse_application_nr
      end

      # @return the english title of the patent
      def title
        @title ||= parse_title
      end

      # @return a list of the IPC-Classifications, as strings. Format is set by
      #   EPO, should be similar to: E06B7/23
      def classifications
        @classifications ||= parse_classification raw
      end

      def agents
        @agents ||= parse_agents raw
      end

      def applicants
        @applicants ||= parse_applicants raw
      end

      # @return the string representation of the current patent status as
      #   described by the EPO
      def status
        @status ||= parse_status raw
      end

      # @return the latest date found in the document. The fields
      #   `change_gazette_num` are considered for this and parsed.
      def latest_update
        @latest ||= parse_latest_update raw
      end

      # @return a hash which descibes the files priority with the fields:
      #   `country` `doc_number`, `date`, `kind`, and `sequence`
      def priority_date
        @priority_date ||= parse_priority_date raw
      end

      # @return List of hashes containing information about publications made,
      #   entries exist for multiple types of publications, e.g. A1, B1.
      def publication_dates
        @publication_dates ||= parse_publication_dates raw
      end

      def effective_date
        @effective_date ||= parse_effective_date raw
      end

      # string, string, string, string ,string, string(length:2), Date, string
      # I do not know yet what is stored in `cdsid`, but when it can be used to
      # identify agents or applicants it may get useful.
      Address = Struct.new(:name, :address1, :address2, :address3, :address4, :address5, :country_code, :last_occurred_on, :cdsid) do
        def initialize(*)
          super
          self.address1 ||= ''
          self.address2 ||= ''
          self.address3 ||= ''
          self.address4 ||= ''
          self.address5 ||= ''
        end

        def equal_name_and_address?(other)
          name == other.name &&
          address1 == other.address1 &&
          address2 == other.address2 &&
          address3 == other.address3 &&
          address4 == other.address4 &&
          address5 == other.address5
        end

        def name_and_address_hash
          {name: name, address1: address1, address2: address2, address3: address3, address4: address4, address5: address5}
        end
      end

      private

      def parse_title
        titles = Epo::Ops::Util.find_in_data(raw, path_to_bibliographic_data + ['invention_title'])
        titles.each do |the_title|
          return the_title['__content__'] if the_title['lang'] == 'en'
        end
        # no english title found
        titles.first['__content__']
      end

      def parse_application_nr
        path = %w(world_patent_data register_search query __content__)
        Epo::Ops::Util.find_in_data(raw, path).first.partition('=').last
      end

      def parse_priority_date(raw)
        priority_claims = Epo::Ops::Util.find_in_data(raw, path_to_bibliographic_data + %w(priority_claims)).first
        if priority_claims.nil?
          priority_date = nil
        else
          priority_date = priority_claims['priority_claim'].is_a?(Hash) ? priority_claims['priority_claim'] : priority_claims['priority_claim'].first
        end
        priority_date
      end

      def parse_publication_dates(raw)
        Epo::Ops::Util.parse_hash_flat(
          Epo::Ops::Util.find_in_data(raw,
            path_to_bibliographic_data + %w(publication_reference)), "document_id")
      end

      def parse_effective_date(raw)
        effective_date = Epo::Ops::Util.find_in_data(raw, path_to_bibliographic_data + %w(dates_rights_effective request_for_examination))
        effective_date.first.nil? ? nil : effective_date.first['date']
      end

      def parse_latest_update(raw)
        gazette_nums = Epo::Ops::Util.parse_hash_flat(raw, 'change_gazette_num')
        nums = gazette_nums.map { |num| Epo::Ops::Util.parse_change_gazette_num(num) }.keep_if { |match| !match.nil? }
        nums.max
      end

      def parse_status(raw)
        Epo::Ops::Util.find_in_data(raw, path_to_bibliographic_data + ['status']).first
      end

      def parse_classification(raw)
        Epo::Ops::Util.find_in_data(raw, path_to_bibliographic_data + %w(classifications_ipcr classification_ipcr text)).first.split(',').map(&:strip)
      end

      def parse_agents(raw)
        entries = Epo::Ops::Util.find_in_data(raw, path_to_bibliographic_data + %w(parties agents))
        parse_address(entries, 'agent')
      end

      def parse_applicants(raw)
        entries = Epo::Ops::Util.find_in_data(raw, path_to_bibliographic_data + %w(parties applicants))
        parse_address(entries, 'applicant')
      end


      def parse_address(party_group_entries, group)
        party_group_entries.flat_map do |entry|
          change_date = Epo::Ops::Util.parse_change_gazette_num(entry.fetch('change_gazette_num', '')) || latest_update
          Epo::Ops::Util.find_in_data(entry, [group,"addressbook"]).map do |address|
            Address.new(address['name'], address['address']['address_1'], address['address']['address_2'], address['address']['address_3'], address['address']['address_4'], address['address']['address_5'], address['address']['country'], change_date, address['cdsid'])
          end
        end
      end

      def path_to_bibliographic_data
        %w(world_patent_data register_search register_documents register_document bibliographic_data)
      end
    end
  end
end
