require 'epo/token_store'

module Epo
  module Ops
    class Client
      def initialize
        @token_store = Epo::Ops.config.token_store
      end

      def request(verb, url, options = {})
        response = token.request(verb, url, options)

        raise Epo::Error.from_response(response) unless response.status == 200

        response
      end
    end
  end
end
