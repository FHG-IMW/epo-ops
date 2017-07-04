require 'oauth2'
require 'epo/ops'

module Epo
  module Ops
    # This class saves the token in memory, you may want to subclass this and
    # overwrite #token if you want to store it somewhere else.
    #
    class TokenStore
      def token
        @token = generate_token if !@token || @token.expired?

        @token
      end

      def reset
        @token = nil
      end

      protected

      def generate_token
        client = OAuth2::Client.new(
          Epo::Ops.config.consumer_key,
          Epo::Ops.config.consumer_secret,
          site: 'https://ops.epo.org/',
          token_url: "/#{Epo::Ops::API_VERSION}/auth/accesstoken",
          raise_errors: false
        )

        client.client_credentials.get_token
      end
    end
  end
end
