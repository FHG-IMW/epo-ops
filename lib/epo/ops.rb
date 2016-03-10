require 'epo/ops/version'
require 'epo/ops/token_store'
require 'epo/ops/register'
require 'epo/ops/search_query_builder'
require 'epo/ops/ipc_class_hierarchy_loader'
require 'epo/ops/ipc_class_util'
require 'core_ext'

module Epo
  module Ops
    # Configure your OAuth credentials to use with this gem.
    # @example
    #   Epo:Ops.configure do |conf|
    #     conf.consumer_key = "foo"
    #     conf.consumer_secret = "bar"
    #   end
    # Optional parameter:
    # conf.token_store (defaults to {Epo::Ops::TokenStore})
    # @yieldparam [Configuration] configuration that is yielded.
    def self.configure
      yield(config)
    end

    # The {Configuration} used. You may want to call {Epo::Ops#configure} first.
    # @return [Configuration] the configuration used.
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
