require 'epo/ops/version'
require 'epo/ops/token_store'
require 'epo/ops/register'
require 'epo/ops/search_query_builder'

module Epo
  module Ops
    # Usage
    # Epo:Ops.configure do |conf|
    # conf.consumer_key = "foo"
    # conf.consumer_secret = "bar"
    # conf.token_store = ... (optional, uses [TokenStore] by default)
    # end
    def self.configure
      yield(config)
    end

    def self.config
      @configuration ||= Configuration.new
    end

    class Configuration
      attr_accessor :consumer_key, :consumer_secret, :token_store

      def initialize
        @consumer_key = ''
        @consumer_secret = ''
        @token_store = Epo::Ops::TokenStore.new

        OAuth2::Response.register_parser(:xml, ['application/xml']) do |body|
          MultiXml.parse(body)
        end
      end
    end
  end
end
