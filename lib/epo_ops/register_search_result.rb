module EpoOps
  # A simple wrapper for register search query result.
  class RegisterSearchResult
    include Enumerable

    def initialize(patents,count,raw_data = nil)
      @patents = patents
      @count = count
      @raw_data = raw_data
    end

    # The number of patents that match the query string. Offsets and API query limits do not apply
    # so that the actual number of patents returned can be much smaller.
    # @see EpoOps::Limits
    # @return [integer] The number of applications matching the query.
    attr_reader :count

    # @return [Array] the patents returned by the search. Patentapplication data is not complete
    attr_reader :patents

    def each
      patents.each do |patent|
        yield(patent)
      end
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
