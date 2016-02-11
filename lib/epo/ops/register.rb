require 'epo/ops'
require 'epo/ops/client'

module Epo
  module Ops
    class Register

      # @param query A query built with {Epo::Ops::SearchQueryBuilder}
      # @return parsed response
      # TODO parse response
      def self.search(query)
        Epo::Ops::Client.request(:get, "/3.1/rest-services/register/#{query}")
      end
    end
  end
end
