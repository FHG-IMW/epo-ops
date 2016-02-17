require 'epo/ops'
require 'epo/ops/client'

module Epo
  module Ops
    class Register

      # @param query A query built with {Epo::Ops::SearchQueryBuilder}
      # @return parsed response
      def self.search(query)
        Client.request(:get, "/3.1/rest-services/register/#{query}").parsed
      end
    end
  end
end
