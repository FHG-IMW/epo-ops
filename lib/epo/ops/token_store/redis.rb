require 'redis'
require 'connection_pool'

module Epo
  module Ops
    class TokenStore
      class Redis < TokenStore
        def initialize(redis_host)
          raise "Please install gems 'redis' and 'connection_pool' to use this feature" unless defined?(::Redis) && defined?(ConnectionPool)

          @redis = ConnectionPool.new(size: 5, timeout: 5) { ::Redis.new(host: redis_host) }
        end

        def token
          token = nil
          @redis.conn do |conn|
            token = conn.get("epo_token_#{id}")
          end

          token.present? ? OAuth2::AccessToken.new(client, token) : generate_token
        end

        private

        def generate_token
          super
          Sidekiq.redis do |conn|
            conn.set("epo_token_#{id}", token.token, ex: token.expires_in, nx: true)
          end
          token
        end
      end
    end
  end
end
