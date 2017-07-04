require 'epo/ops'
require 'epo/ops/client'
require 'epo/ops/util'
require 'epo/ops/bibliographic_document'
require 'epo/ops/logger'
require 'epo/ops/ipc_class_util'

module Epo
  module Ops
    # Access to the {http://ops.epo.org/3.2/rest-services/register register}
    # endpoint of the EPO OPS API.
    #
    # By now you can search and retrieve patents by using the type `application`
    # in the `epodoc` format.
    #
    # Search queries are limited by size, not following these limits
    # will result in errors. You should probably use {.search} which handles the
    # limits itself.
    #
    # For more fine grained control use {.raw_search} and {.raw_biblio}
    #
    # @see Limits
    # @see SearchQueryBuilder
    class Register
      # A helper method which creates queries that take API limits into account.
      # @param patent_count [Integer] number of overall results expected.
      #   See {.published_patents_count}
      #
      # @return [Array] of Strings, each a query to put into {Register.raw_search}
      # @see Epo::Ops::Limits
      def self.split_by_size_limits(ipc_class, date, patent_count)
        max_interval = Limits::MAX_QUERY_INTERVAL
        (1..patent_count).step(max_interval).map do |start|
          range_end = [start + max_interval - 1, patent_count].min
          Epo::Ops::SearchQueryBuilder.build(ipc_class, date, start, range_end)
        end
      end

      # Makes the requests to find how many patents are in each top
      # level ipc class on a given date.
      #
      # @param date [Date] date on which patents should be counted
      # @return [Hash] Hash ipc_class => count (ipc_class A-H)
      def self.patent_counts_per_ipc_class(date)
        %w( A B C D E F G H ).inject({}) do |mem, icc|
          mem[icc] = published_patents_counts(icc, date)
          mem
        end
      end

      # @param date [Date]
      # @param ipc_class [String] up to now should only be between A-H
      # @return [Integer] number of patents with given parameters
      def self.published_patents_counts(ipc_class = nil, date = nil)
        query = SearchQueryBuilder.build(ipc_class, date, 1, 2)
        minimum_result_set = Register.raw_search(query, true)
        return 0 if minimum_result_set.empty?
        minimum_result_set['world_patent_data']['register_search']['total_result_count'].to_i
      end

      # Search method returning all unique register references on a given
      # date, with optional ipc_class.
      # @note This method does more than one query; it may happen that you
      #   exceed your API limits
      # @return [Array] Array of {SearchEntry}
      def self.search(ipc_class = nil, date = nil)
        queries = all_queries(ipc_class, date)
        search_entries = queries.flat_map { |query| raw_search(query) }
        search_entries.uniq { |se| se.application_reference.epodoc_reference }
      end

      # @return [Array] Array of Strings containing queries applicable to
      #   {Register.raw_search}.
      # builds all queries necessary to find all patent references on a given
      # date.
      def self.all_queries(ipc_class = nil, date = nil)
        count = published_patents_counts(ipc_class, date)
        if count > Limits::MAX_QUERY_RANGE
          IpcClassUtil.children(ipc_class).flat_map { |ic| all_queries(ic, date) }
        else
          split_by_size_limits(ipc_class, date, count)
        end
      end

      # @param query A query built with {Epo::Ops::SearchQueryBuilder}
      # @param raw if `true` the result will be the raw response as a nested
      #   hash. if false(default) the result will be parsed further, returning a
      #   list of [SearchEntry]
      # @return [Array] containing {SearchEntry}
      def self.raw_search(query, raw = false)
        hash = Client.request(:get, register_api_string + 'search?' + query).parsed
        return parse_search_results(hash) unless raw
        hash
      rescue Epo::Ops::Error::NotFound
        []
      end

      # @param search_entry [SearchEntry] a search entry which should be
      #   retrieved.
      # @return [BibliographicDocument] a parsed document.
      def self.biblio(search_entry)
        raw_biblio(search_entry.application_reference.epodoc_reference)
      end

      # @param reference_id [String] identifier for document. Format similar to
      #   EP1000000
      # @param format [String] epodoc is a format defined by the EPO for a
      #   document id. see their documentation.
      # @param type [String] may be `application` or `publication` make sure
      #   that the `reference_id` is matching
      # @param raw [Boolean] flag if the result should be returned as a raw Hash
      #   or parsed as {BibliographicDocument}
      # @return [BibliographicDocument, Hash]
      def self.raw_biblio(reference_id, type = 'application', format = 'epodoc', raw = false)
        request = "#{register_api_string}#{type}/#{format}/#{reference_id}/biblio"
        result = Client.request(:get, request).parsed
        raw ? result : BibliographicDocument.new(result)
      end

      Reference = Struct.new(:country, :doc_number, :date) do
        def epodoc_reference
          country + doc_number
        end
      end

      SearchEntry = Struct.new(:publication_reference, :application_reference, :ipc_classes)

      private

      def self.parse_search_results(result)
        path = %w(world_patent_data register_search register_documents register_document bibliographic_data)

        list = Util.find_in_data(result, path)
        list.map do |entry|
          publication_reference = Reference.new(
            entry['publication_reference']['document_id']['country'],
            entry['publication_reference']['document_id']['doc_number'],
            entry['publication_reference']['document_id']['date'])
          application_reference = Reference.new(
            entry['application_reference']['document_id']['country'],
            entry['application_reference']['document_id']['doc_number'])
          ipc_classes = entry['classifications_ipcr']['classification_ipcr']['text'].split(';;').map(&:strip)
          SearchEntry.new(publication_reference, application_reference, ipc_classes)
        end
      end

      def self.register_api_string
        "/#{Epo::Ops::API_VERSION}/rest-services/register/"
      end
    end
  end
end
