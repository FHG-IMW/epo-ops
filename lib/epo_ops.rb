require 'epo_ops/version'
require 'epo_ops/token_store'
require 'epo_ops/register'
require 'epo_ops/search_query_builder'
require 'epo_ops/ipc_class_hierarchy_loader'
require 'epo_ops/ipc_class_util'
require 'epo_ops/patent_application'
require 'epo_ops/name_and_address'
require 'epo_ops/factories'
require 'epo_ops/register_search_result'

module EpoOps
  # Configure authentication method and credentials
  # @example
  #   EpoOps.configure do |conf|
  #     conf.consumer_key = "foo"
  #     conf.consumer_secret = "bar"
  #     conf.token_store = EpoOps::TokenStore::Redis # (defaults to EpoOps::TokenStore)
  #     conf.authentication :oauth # or :plain (defaults to :oauth)
  #   end
  # @yieldparam [Configuration] configuration that is yielded.
  def self.configure
    yield(config)
  end

  # The {Configuration} used. You may want to call {EpoOps#configure} first.
  # @return [Configuration] the configuration used.
  def self.config
    @configuration ||= Configuration.new
  end

  class Configuration
    attr_accessor :consumer_key, :consumer_secret, :token_store, :authentication

    def initialize
      @consumer_key = ''
      @consumer_secret = ''
      @token_store = EpoOps::TokenStore.new
      @authentication = :oauth

      OAuth2::Response.register_parser(:xml, ['application/xml']) do |body|
        MultiXml.parse(body)
      end
    end
  end
end
