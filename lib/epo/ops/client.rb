require 'epo/ops/token_store'

module Epo
  module Ops
    class Client
      def self.request(verb, url, options = {})
        token = Epo::Ops.config.token_store.token
        response = token.request(verb, url, options)

        raise Epo::Error.from_response(response) unless response.status == 200

        response
      end
    end
  end
end
