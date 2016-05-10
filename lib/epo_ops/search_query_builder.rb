require 'epo_ops/limits'
require 'epo_ops/logger'

module EpoOps
  # This Builder helps creating a search query using
  # {https://www.loc.gov/standards/sru/cql/ CQL} (Common Query Language or
  # Contextual Query Language) with the identifiers specified by the EPO in
  # the OPS Documentation chapter 4.2 ({https://www.epo.org/searching-for-patents/technical/espacenet/ops.html Link})
  # - use tab Downloads and see file 'OPS version 3.1 documentation').
  class SearchQueryBuilder
    # Build the query with the given parameters. Invalid ranges are fixed
    # automatically and you will be notified about the changes
    # @return [String]
    def self.build(ipc_class, date, range_start = nil, range_end = nil)
      validated_range = validate_range range_start, range_end
      "q=#{build_params(ipc_class, date)}&Range=#{validated_range[0]}-#{validated_range[1]}"
    end

    private

    def self.build_params(ipc_class, date)
      [build_date(date), build_class(ipc_class)].compact.join(' and ')
    end

    def self.build_date(date)
      if date
        "pd=#{('%04d' % date.year)}"\
        "#{('%02d' % date.month)}"\
        "#{('%02d' % date.day)}"
      end
    end

    def self.build_class(ipc_class)
      "ic=#{ipc_class}" if ipc_class
    end

    # Fixes the range given so that they meed the EPO APIs rules. The range
    #  may only be 100 elements long, the maximum allowed value is 2000.
    # If the given window is out of range, it will be moved preserving the
    # distance covered.
    # @see EpoOps::Limits
    # @return array with two elements: [range_start, range_end]
    def self.validate_range(range_start, range_end)
      range_start = 1 unless range_start
      range_end = 10 unless range_end
      if range_start > range_end
        range_start, range_end = range_end, range_start
        Logger.debug('range_start was bigger than range_end, swapped values')
      elsif range_end - range_start > Limits::MAX_QUERY_INTERVAL - 1
        range_end = range_start + Limits::MAX_QUERY_INTERVAL - 1
        Logger.debug("range invalid, set to: #{[range_start, range_end]}")
      end
      if range_start < 1
        range_end = range_end - range_start + 1
        range_start = 1
        Logger.debug("range_start must be > 0, set to: #{[range_start, range_end]}")
      elsif range_end > Limits::MAX_QUERY_RANGE
        range_start = Limits::MAX_QUERY_RANGE - (range_end - range_start)
        range_end = Limits::MAX_QUERY_RANGE
        Logger.debug("range_end was too big, set to: #{[range_start, range_end]}")
      end
      [range_start, range_end]
    end
  end
end
