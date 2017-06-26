module EpoOps
  module Factories
    # Parses the register search result from EPO Ops into an RegisterSearchResult object
    class RegisterSearchResultFactory
      class << self

        # @param raw_data [Hash] raw search result as retrieved from Epo Ops
        # @return [EpoOps::RegisterSearchResult] RegisterSearchResult filled with parsed data
        def build(raw_data)
          factory = new(raw_data)

          EpoOps::RegisterSearchResult.new(
            factory.patents,
            factory.count,
            factory.raw_data
          )
        end
      end

      attr_reader :raw_data

      def initialize(raw_data)
        @raw_data = raw_data
      end

      # @return [integer] The number of applications matching the query
      # @see EpoOps::RegisterSearchResult#count
      def count
        EpoOps::Util.dig(@raw_data, 'world_patent_data', 'register_search', 'total_result_count').to_i
      end

      # @return [Array] the patents returned by the search. Patentapplication data is not complete
      # @see EpoOps::RegisterSearchResult#patents
      def patents
        EpoOps::Util.flat_dig(
          @raw_data,
          %w[world_patent_data register_search register_documents register_document]
        ).map {|patent_data| EpoOps::Factories::PatentApplicationFactory.build(patent_data)}
      end
    end
  end
end
