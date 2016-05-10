require 'epo_ops'
require 'epo_ops/client'
require 'epo_ops/util'
require 'epo_ops/logger'
require 'epo_ops/ipc_class_util'

module EpoOps
  # Access to the {http://ops.epo.org/3.1/rest-services/register register}
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
    # @see EpoOps::Limits
    def self.split_by_size_limits(ipc_class, date, patent_count)
      max_interval = Limits::MAX_QUERY_INTERVAL
      (1..patent_count).step(max_interval).map do |start|
        range_end = [start + max_interval - 1, patent_count].min
        EpoOps::SearchQueryBuilder.build(ipc_class, date, start, range_end)
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
      minimum_result_set = Register.raw_search(query)
      minimum_result_set.count
    end

    # Search method returning all unique register references on a given
    # date, with optional ipc_class.
    # @note This method does more than one query; it may happen that you
    #   exceed your API limits
    # @return [Array] Array of {SearchEntry}
    def self.search(ipc_class = nil, date = nil)
      queries = all_queries(ipc_class, date)
      search_entries = queries.map { |query| raw_search(query) }
      applications = search_entries.collect(&:patents)

      EpoOps::RegisterSearchResult.new(applications,applications.count)
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

    # @param query A query built with {EpoOps::SearchQueryBuilder}
    # @param raw if `true` the result will be the raw response as a nested
    #   hash. if false(default) the result will be parsed further, returning a
    #   list of [SearchEntry]
    # @return [RegisterSearchResult]
    def self.raw_search(query, raw = false)
      data = Client.request(
        :get,
        '/3.1/rest-services/register/search?' + query
      ).parsed

      EpoOps::Factories::RegisterSearchResultFactory.build(data)
    rescue EpoOps::Error::NotFound
      raw ? nil : EpoOps::RegisterSearchResult::NullResult.new
    end
  end
end
