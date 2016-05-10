require 'oauth2'
require 'epo_ops'

module EpoOps
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
        EpoOps.config.consumer_key,
        EpoOps.config.consumer_secret,
        site: 'https://ops.epo.org/',
        token_url: '/3.1/auth/accesstoken',
        raise_errors: false
      )

      client.client_credentials.get_token
    end
  end
end
