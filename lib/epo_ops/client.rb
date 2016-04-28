require 'epo_ops/token_store'
require 'epo_ops/error'

module EpoOps

  # This is a wrapper for OAuth
  class Client


    # @return [OAuth2::Response]
    # @option options [Hash] :params query parameter for the request
    # @option options [Hash, String] :body the body of the request
    # @option options [Hash] :headers http request headers
    # @raise [EpoOps::Error] API Error if request was not successful
    def self.request(verb, url, options = {})
      response = case EpoOps.config.authentication
                  when :oauth then do_oauth_request(verb, url, options)
                  when :plain then do_plain_request(verb,url,options)
                  else raise('Unknown authentication strategy!')
                 end
      fail Error.from_response(response) unless response.status == 200
      response
    rescue Error::AccessTokenExpired
      EpoOps.config.token_store.reset
      request(verb, url, options)
    end

    private

    # Make an oauth request to the EPO API
    # @return [OAuth2::Response]
    def self.do_oauth_request(verb, url, options = {})
      token = EpoOps.config.token_store.token
      token.request(verb, URI.encode(url), options)
    end

    # Make an anonymous request to the EPO API
    # @return [OAuth2::Response] OAuth2::Reponse is used for convenience and consistency
    def self.do_plain_request(verb, url, options = {})
      conn = Faraday.new("https://ops.epo.org/")
      url = conn.build_url(url, options[:params]).to_s
      response = conn.run_request(verb,url,options[:body], options[:header])
      OAuth2::Response.new(response)
    end
  end
end
