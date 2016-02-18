require 'epo/ops'
require 'epo/ops/client'
require 'epo/ops/util'
require 'epo/ops/bibliographic_document'
require 'epo/ops/logger'

module Epo
  module Ops
    class Register
      # class to bulk retrieve information from the register
      class Bulk
        # The offset of EPOs register search may at max be 2000, if more patents
        # are published on one day the queries must be split; here across the
        # first level of ipc classification.
        # At time of this writing they are mostly below 1000, there should be
        # plenty of space for now.
        # In case the limits change, they can be found in [Epo::Ops::Limits]
        # Should there be more than 2000 patents in one class, a message will
        # be logged, please file an Issue if that happens.
        def self.all_queries(date)
          overall_count = published_patents_count(date)
          if overall_count > Limits.MAX_QUERY_RANGE
            patent_count_by_ipc_classes(date).flat_map do |ipc_class, count|
              builder = SearchQueryBuilder.new
                                                    .publication_date(date.year, date.month, date.day)
                                                    .and
                                                    .ipc_class(ipc_class)
              split_by_size_limits(builder, count)
            end
          else
            builder = SearchQueryBuilder.new
                                                  .publication_date(date.year, date.month, date.day)
            split_by_size_limits(builder, overall_count)
          end
        end

        def self.patent_count_by_ipc_classes(date)
          ipc_classes = %w(A B C D E F G H)
          ipc_classes.inject({}) do |mem, ipcc|
            mem[ipcc] = published_patents_count(date, ipcc)
            if mem[ipcc] > Limits.MAX_QUERY_RANGE
              Logger.log("IPC class #{ipcc} has more than #{Epo::Ops::Limits.MAX_QUERY_RANGE} on #{date}. They can not all be retrieved. Please file this as an issue!")
            end
            mem
          end
        end

        def self.split_by_size_limits(query_builder, patent_count)
          max_interval = Limits.MAX_QUERY_INTERVAL
          (1..patent_count).step(max_interval).map do |start|
            query_builder.build(start, [start + max_interval - 1, patent_count].min)
          end
        end

        # make a minimum request to find out how many patents are published on that date
        def self.published_patents_count(date, ipc_class= nil)
          query = SearchQueryBuilder.new
          query.publication_date(date.year, date.month, date.day)
          query.and.ipc_class(ipc_class) if ipc_class
          query = query.build(1, 2)
          minimum_result_set = Register.search(query, true)
          return 0 if minimum_result_set.empty?
          minimum_result_set['world_patent_data']['register_search']['total_result_count'].to_i
        end
      end

      # @param query A query built with {Epo::Ops::SearchQueryBuilder}
      # @param raw if `true` the result will be the raw response as a nested hash.
      # if false(default) the result will be parsed further, returning a list of [SearchEntry]
      # @return parsed response
      def self.search(query, raw= false)
        hash = Client.request(:get, register_api_string + query).parsed
        return parse_search_results(hash) unless raw
        hash
      end

      # @param format epodoc is a format defined by the EPO for a
      # document id. see their documentation.
      # @param type may be `application` or `publication` make sure that the
      # `reference_id` is matching
      def self.biblio(reference_id, type = 'application', format = 'epodoc')
        request = "#{register_api_string}#{type}/#{format}/#{reference_id}/biblio"
        BibliographicDocument.new(Client.request(:get, request).parsed)
      end

      Reference = Struct.new(:country, :doc_number, :date) do
        def epodoc_reference
          country + doc_number
        end
      end

      SearchEntry = Struct.new(:publication_reference, :application_reference, :ipc_classes)

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
        '/3.1/rest-services/register/'
      end
    end
  end
end
