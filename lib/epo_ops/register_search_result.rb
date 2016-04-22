module EpoOps
  # A simple wrapper for register search query result.
  class RegisterSearchResult
    include Enumerable

    def initialize(data)
      @data = data
    end

    # The number of patents that match the query string. Offsets and API query limits do not apply
    # so that the actual number of patents returned can be much smaller.
    # @see EpoOps::Limits
    # @return [integer] The number of applications matching the query.
    def count
      return @count if @count
      @count = EpoOps::Util.dig(@data, 'world_patent_data', 'register_search', 'total_result_count').to_i
    end

    def each
      patents.each do |patent|
        yield(patent)
      end
    end

    # @return [Array] the patents returned by the search. Patentapplication data is not complete
    def patents
      @patents ||= EpoOps::Util.flat_dig(
        @data,
        %w(world_patent_data register_search register_documents register_document)
      ).map {|patent_data| EpoOps::Factories::PatentApplicationFactory.build(patent_data)}
    end

    # Represents queries with no results
    class NullResult < EpoOps::RegisterSearchResult
      def initialize(data=nil) ; end

      def count
        0
      end

      def patents
        []
      end
    end
  end
end
