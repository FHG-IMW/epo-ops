require 'epo/ops/token_store'
require 'epo/ops/error'

module Epo
  module Ops

    # This is a wrapper for OAuth
    class Client
      # @return [OAuth2::Response]
      def self.request(verb, url, options = {})
        do_request(verb, url, options)
      rescue Error::AccessTokenExpired
        Epo::Ops.config.token_store.reset
        do_request(verb, url, options)
      end

      private

      def self.do_request(verb, url, options = {})
        token = Epo::Ops.config.token_store.token
        response = token.request(verb, URI.encode(url), options)
        fail Error.from_response(response) unless response.status == 200
        response
      end
    end
  end
end
