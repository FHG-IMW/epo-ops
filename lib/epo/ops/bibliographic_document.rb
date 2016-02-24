module Epo
  module Ops
    # Parses and simplifies the elements the EPO OPS returns for bibliographic
    # documents. Parsing is done lazily.
    # Some elements are not yet fully parsed but hashes returned instead.
    # Not all information available is parsed (e.g. inventors), if you need
    # more fields, add them here.
    class BibliographicDocument

      # @return [Hash] a nested Hash, which is a parsed XML response of the
      #   `/biblio` endpoint of the EPO APIs.
      # @see Client
      attr_reader :raw

      def initialize(raw)
        @raw = raw
      end

      def application_nr
        @application_nr ||= parse_application_nr
      end

      def url
        @url ||= "https://ops.epo.org/rest-services/register/application/epodoc/#{application_nr}"
      end

      # @return the english title of the patent
      # @note Titles are usually available at least in english, french and german.
      #   Other languages are also possible.
      def title
        @title ||= parse_title
      end

      # @return a list of the IPC-Classifications, as strings. Format is set by
      #   EPO, should be similar to: E06B7/23
      def classifications
        @classifications ||= parse_classification raw
      end

      # @return Array of Structs with the following fields: name,
      #   address(1-5), country_code, last_occurred_on, cdsid.
      #
      # address1 and address2 should always contain values, the rest
      # may be empty strings.  Agents and applicants are subject to
      # change at EPO, often their names or addresses are updated,
      # sometimes other people/companies appear or disappear. In the
      # raw data most entries have an attribute `change_gazette_num`,
      # which is a commercial date (year + week) describing when this
      # entry was changed. Unfortunately new entries often do not have
      # this attribute though. `last_occurred_on` should parse the date.      #
      def agents
        @agents ||= parse_agents raw
      end

      # (see #agents)
      def applicants
        @applicants ||= parse_applicants raw
      end

      # @return the string representation of the current patent status as
      #   described by the EPO
      def status
        @status ||= parse_status raw
      end

      # Many fields of the XML the EPO provides have a field
      # `change_gazette_num`.  It is a commercial date (year + week)
      # that describes in which week the element has been
      # changed. This method parses them and returns the most recent
      # date found.
      # @return [Date] the latest date found in the document.
      def latest_update
        @latest ||= parse_latest_update raw
      end

      # The priority date describes the first document that was filed at any
      # patent office in the world regarding this patent.
      # @return [Hash] a hash which descibes the filed priority with the fields:
      #   `country` `doc_number`, `date`, `kind`, and `sequence`
      def priority_date
        @priority_date ||= parse_priority_date raw
      end

      # @return [Array] List of hashes containing information about publications
      #   made, entries exist for multiple types of publications, e.g. A1, B1.
      def publication_references
        @publication_dates ||= parse_publication_references raw
      end

      def effective_date
        @effective_date ||= parse_effective_date raw
      end

      # Used to represent persons or companies (or both) in patents. Used for
      # both, agents and applicants. Most of the time, when `name` is a person
      # name, `address1` is a company name. Be aware that the addresses are in
      # their respective local format.
      # @attr [String] name the name of an entity (one or more persons or
      #   companies)
      # @attr [String] address1 first address line. May also be a company name
      # @attr [String] address2 second address line
      # @attr [String] address3 third address line, may be empty
      # @attr [String] address4 fourth address line, may be empty
      # @attr [String] address5 fifth address line, may be empty
      # @attr [String] country_code two letter country code of the address
      # @attr [Date] last_occurred_on TODO
      # @attr [String] cdsid some kind of id the EPO provides, not sure yet if
      #   usable as reference.
      class Address
        attr_reader :name, :address1,
                           :address2,
                           :address3,
                           :address4,
                           :address5,
                           :country_code,
                           :last_occurred_on,
                           :cdsid
        def initialize(name, address1, address2, address3, address4,
                       address5, country_code, last_occurred_on,
                       cdsid)
          @address1 = address1
          @address2 = address2
          @address3 = address3 || ''
          @address4 = address4 || ''
          @address5 = address5 || ''
          @name = name
          @country_code = country_code || ''
          @last_occurred_on = last_occurred_on || ''
          @cdsid = cdsid || ''
        end

        # Compare addresses by the name and address fields.
        # @return [Boolean]
        def equal_name_and_address?(other)
          name == other.name &&
            address1 == other.address1 &&
            address2 == other.address2 &&
            address3 == other.address3 &&
            address4 == other.address4 &&
            address5 == other.address5
        end

      end

      private

      def parse_title
        titles = Util.find_in_data(raw,
                                   path_to_bibliographic_data +
                                   ['invention_title'])
        titles.each do |the_title|
          return the_title['__content__'] if the_title['lang'] == 'en'
        end
        # no english title found
        titles.first['__content__']
      end

      def parse_application_nr
        path = %w(world_patent_data register_search query __content__)
        Util.find_in_data(raw, path).first.partition('=').last
      end

      def parse_priority_date(raw)
        priority_claims = Util.find_in_data(raw,
                                            path_to_bibliographic_data +
                                            %w(priority_claims))
                          .first
        if priority_claims.nil?
          priority_date = nil
        else
          priority_date = priority_claims['priority_claim'].is_a?(Hash) ? priority_claims['priority_claim'] : priority_claims['priority_claim'].first
        end
        priority_date
      end

      def parse_publication_references(raw)
        Util.parse_hash_flat(
          Util.find_in_data(raw,
                            path_to_bibliographic_data +
                            %w(publication_reference)), 'document_id')
      end

      def parse_effective_date(raw)
        effective_date =
          Util.find_in_data(raw,
                            path_to_bibliographic_data +
                            %w(dates_rights_effective request_for_examination))
        effective_date.first.nil? ? nil : effective_date.first['date']
      end

      def parse_latest_update(raw)
        gazette_nums = Util.parse_hash_flat(raw, 'change_gazette_num')
        nums = gazette_nums.map { |num| Util.parse_change_gazette_num(num) }.keep_if { |match| !match.nil? }
        nums.max
      end

      def parse_status(raw)
        Util.find_in_data(raw,
                          path_to_bibliographic_data + ['status'])
          .first
      end

      def parse_classification(raw)
        Util.find_in_data(raw,
                          path_to_bibliographic_data +
                          %w(classifications_ipcr classification_ipcr text))
          .first.split(',').map(&:strip)
      end

      def parse_agents(raw)
        entries = Util.find_in_data(raw,
                                    path_to_bibliographic_data +
                                    %w(parties agents))
        parse_address(entries, 'agent')
      end

      def parse_applicants(raw)
        entries = Util.find_in_data(raw,
                                    path_to_bibliographic_data +
                                    %w(parties applicants))
        parse_address(entries, 'applicant')
      end

      def parse_address(party_group_entries, group)
        party_group_entries.flat_map do |entry|
          change_date = Util.parse_change_gazette_num(
            entry.fetch('change_gazette_num', '')) || latest_update
          Util.find_in_data(entry, [group, 'addressbook']).map do |address|
            Address.new(address['name'],
                        address['address']['address_1'],
                        address['address']['address_2'],
                        address['address']['address_3'],
                        address['address']['address_4'],
                        address['address']['address_5'],
                        address['address']['country'],
                        change_date,
                        address['cdsid'])
          end
        end
      end

      def path_to_bibliographic_data
        %w(world_patent_data register_search register_documents register_document bibliographic_data)
      end
    end
  end
end
