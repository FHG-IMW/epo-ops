require 'epo/ops/version'

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
        @token_store = TokenStore.new
      end
    end
  end
end
