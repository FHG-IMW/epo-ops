module EpoOps
  # This class represents a Patent Application as returned by EPO OPS returns for bibliographic
  # documents.
  # Some elements are not yet fully parsed but hashes returned instead.
  # Not all information available is parsed, but the full data can be accesses via {#raw_data}
  class PatentApplication

    class << self

      # Finds an application document by application number
      # @param application_number [String] identifies the application document at EPO
      # @return [PatentApplication] the application document, nil if it can't be found
      # @note API url: /3.1/rest-services/register/application/epodoc/#{application_number}/biblio
      def find(application_number)
        raw_data = EpoOps::Client.request(
          :get,
          "/3.1/rest-services/register/application/epodoc/#{application_number}/biblio"
        ).parsed

        data = EpoOps::Util.flat_dig(
          raw_data,
          'world_patent_data', 'register_search', 'register_documents', 'register_document'
        ).first

        return nil unless data

        Factories::PatentApplicationFactory.build(data)
      end

      # Searches for application documents using a CQl query
      # @see EpoOps::SearchQueryBuilder
      # @see EpoOps::RegisterSearchResult
      # Returned documents are not fully populated with data,
      # only publication references, application id and IPC classes are available
      # to retrive all data use {#fetch}
      #
      # @param cql_query [String] a CQL query string
      # @return [RegisterSearchResult]
      # @note API url: /3.1/rest-services/register/search
      def search(cql_query)
        data = Client.request(
          :get,
          '/3.1/rest-services/register/search?' + cql_query
        ).parsed

        EpoOps::RegisterSearchResult.new(data)
      rescue EpoOps::Error::NotFound
        EpoOps::RegisterSearchResult::NullResult.new
      end
    end

    # A number by which a patent is uniquely identifiable and querieable.
    # The first two letters are the country code of the processing patent
    # office, for european patents this is EP.
    # @return [String] application number.
    attr_reader :application_nr

    # @return [Hash] The raw application data as recived from EPO
    attr_reader :raw_data

    # @return [Array] a list of the IPC-Classifications, as strings.
    #   Format is set by EPO, should be similar to: E06B7/23
    attr_reader :classifications

    # Lists the Applicants of the Application
    # Applicants are subject to change at EPO, often
    # their names or addresses are updated, sometimes other
    # people/companies appear or disappear.
    # @return [Array] Array of {EpoOps::NameAndAddress}
    attr_reader :applicants

    # Lists the Agents of the Application
    # Agents are subject to change at EPO, often
    # their names or addresses are updated, sometimes other
    # people/companies appear or disappear.
    # @return [Array] Array of {EpoOps::NameAndAddress}
    attr_reader :agents

    # Lists the Inventors of the Application
    # Agents are subject to change at EPO, often
    # their names or addresses are updated, sometimes other
    # people/companies appear or disappear.
    # @return [Array] Array of {EpoOps::NameAndAddress}
    attr_reader :inventors

    # @return [String] the string representation of the current patent status as
    #   described by the EPO
    attr_reader :status

    # The priority claim describe the first documents that were filed at any
    # patent office in the world regarding this patent.
    # @return [Array] an Array of hashes which descibe the filed priorities with the fields:
    #   `country` `doc_number`, `date`, `kind`, and `sequence`
    attr_reader :priority_claims

    # @return [Array] List of hashes containing information about publications
    #   made, entries exist for multiple types of publications, e.g. A1, B1.
    attr_reader :publication_references

    attr_reader :effective_date

    def initialize(application_nr, data={})
      @application_nr = application_nr
      data.each_pair do |key,value|
        instance_variable_set("@#{key.to_s}",value)
      end
    end

    # Returns the Application title in the given languages
    # @param lang [Integer] language identifier for the title
    # @return [String] the english title of the patent
    # @note Titles are usually available at least in english, french and german.
    #       Other languages are also possible.
    def title(lang='en')
      return nil unless @title.instance_of?(Hash)
      @title[lang]
    end

    # Many fields of the XML the EPO provides have a field
    # `change_gazette_num`.  It is a commercial date (year + week)
    # that describes in which week the element has been
    # changed. This method parses them and returns the most recent
    # date found.
    # @return [Date] the latest date found in the document.
    def latest_update
      gazette_nums = EpoOps::Util.parse_hash_flat(@raw_data, 'change_gazette_num')
      nums = gazette_nums.map { |num| EpoOps::Util.parse_change_gazette_num(num) }.keep_if { |match| !match.nil? }
      nums.max
    end

    # @return [String] The URL at which you can query the original document.
    def url
      @url ||= "https://ops.epo.org/3.1/rest-services/register/application/epodoc/#{application_nr}"
    end

    # Fetches the same document from the register populating all available fields
    # @see {PatentApplication.find}
    # @return [self]
    def fetch
      raise "Application Number must be set!" unless application_nr

      new_data = self.class.find(application_nr)

      @raw_data = new_data.raw_data
      @title = new_data.instance_variable_get('@title')
      @status = new_data.status
      @agents = new_data.agents
      @applicants = new_data.applicants
      @inventors = new_data.inventors
      @classifications = new_data.classifications
      @priority_claims = new_data.priority_claims
      @publication_references = new_data.publication_references
      @effective_date = new_data.effective_date

      self
    end
  end
end
