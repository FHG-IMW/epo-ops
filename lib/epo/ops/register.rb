require 'epo/ops'
require 'epo/ops/client'
require 'epo/ops/util'

module Epo
  module Ops
    class Register
      # @param query A query built with {Epo::Ops::SearchQueryBuilder}
      # @return parsed response
      def self.search(query)
        hash = Client.request(:get, register_api_string + query).parsed
        parse_search_results(hash)
      end

      # @param format epodoc is a format defined by the EPO for a
      # document id. see their documentation.
      # @param type may be `application` or `publication` make sure that the
      # `reference_id` is matching
      def self.biblio(reference_id, type = 'application', format = 'epodoc')
        request = "#{register_api_string}#{type}/#{format}/#{reference_id}/biblio"
        Client.request(:get, request).parsed
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
        '/3.1/rest-services/register/'
      end
    end
  end
end
