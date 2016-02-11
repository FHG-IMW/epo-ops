require 'epo/ops/limits'
require 'epo/ops/logger'

module Epo
  module Ops
    # This Builder helps creating a search query using
    # {https://www.loc.gov/standards/sru/cql/ CQL} (Common Query Language or
    # Contextual Query Language) with the identifies specified by the EPO in
    # the OPS Documentation chapter 4.2 ( {https://www.epo.org/searching-for-patents/technical/espacenet/ops.html Link}
    # - use tab Downloads and see file 'OPS version 3.1 documentation').
    class SearchQueryBuilder
      def initialize
        @query = 'search?q='
      end

      def publication_date(year, month, day)
        @query << "pd=#{('%04d' % year) << ('%02d' % month) << ('%02d' % day)}"
        self
      end

      def and
        @query << ' and '
        self
      end

      def ipc_class(ipc_class)
        @query << "ic=#{ipc_class}"
        # TODO: ipc_class richtig formatieren
        self
      end

      # builds the search query ready to put into the register API. The
      # parameters are validated with {#validate_range}.
      def build(range_start = 1, range_end = nil)
        range_end ||= range_start + Epo::Ops::Limits.MAX_QUERY_INTERVAL - 1
        validated_range = validate_range range_start, range_end
        @query << "&Range=#{validated_range[0]}-#{validated_range[1]}"
      end

      # Fixes the range given so that they meed the EPO APIs rules. The range
      #  may only be 100 elements long, the maximum allowed value is 2000.
      # If the given window is out of range, it will be moved preserving the
      # distance covered.
      # @see Epo::Ops::Limits
      # @return array with two elements: [range_start, range_end]
      def validate_range(range_start, range_end)
        if range_start > range_end
          range_start, range_end = range_end, range_start
          Epo::Ops::Logger.log('range_start was bigger than range_end, swapped values')
        elsif range_start == range_end || range_end - range_start > Epo::Ops::Limits.MAX_QUERY_INTERVAL - 1
          range_end = range_start + Epo::Ops::Limits.MAX_QUERY_INTERVAL - 1
          Epo::Ops::Logger.log("range invalid, set to: #{[range_start, range_end]}")
        end
        if range_start < 1
          range_end = range_end - range_start + 1
          range_start = 1
          Epo::Ops::Logger.log("range_start must be > 0, set to: #{[range_start, range_end]}")
        elsif range_end > Epo::Ops::Limits.MAX_QUERY_RANGE
          range_start = Epo::Ops::Limits.MAX_QUERY_RANGE - (range_end - range_start)
          range_end = Epo::Ops::Limits.MAX_QUERY_RANGE
          Epo::Ops::Logger.log("range_end was too big, set to: #{[range_start, range_end]}")
        end
        [range_start, range_end]
      end
    end
  end
end
