module Epo
  module Ops
    # The register search is limited by some parameters. With one
    # query one may only request as many as
    # {Epo::Ops::Limits::MAX_QUERY_INTERVAL} references at once.
    # Considering this, you have to split your requests by this
    # interval.  Nevertheless, the maximum value you may use is
    # {Epo::Ops::Limits::MAX_QUERY_RANGE}. If you want to retrieve more
    # references you must split by other parameters.
    # @see Register
    class Limits
      # @return [Integer] The range in which you can search is limited, say you
      #   cannot request all patents of a given class at once, you probably must
      #   split your requests by additional conditions.
      MAX_QUERY_RANGE = 2000

      # @return [Integer] The maximum number of elements you may search with one
      #   query. Ignoring this will result in errors.
      MAX_QUERY_INTERVAL = 100
    end
  end
end
