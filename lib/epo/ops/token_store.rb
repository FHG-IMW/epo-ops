require 'oauth2'

module Epo
  module Ops
    # This class saves the token in memory, you may want to subclass this and
    # overwrite #token if you want to store it somewhere else.
    #
    class TokenStore
      def initialize
        @client = OAuth2::Client.new(
          Epo.config.consumer_key,
          Epo.config.consumer_secret,
          site: 'https://ops.epo.org/',
          token_url: '/3.1/auth/accesstoken',
          raise_errors: false
        )
      end

      def token
        return generate_token if @token || @token.expired?
        @token
      end

      protected

      def generate_token
        @token = @client.client_credentials.get_token
      end
    end
  end
end
