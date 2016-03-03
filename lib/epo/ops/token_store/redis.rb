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
          @redis.with do |conn|
            token = conn.get("epo_token_#{id}")
          end

          token.present? ? OAuth2::AccessToken.new(client, token) : generate_token
        end

        def reset
          @redis.with do |conn|
            conn.del("epo_token_#{id}")
          end
        end

        private

        def id
          Digest::MD5.hexdigest(Epo::Ops.config.consumer_key+Epo::Ops.config.consumer_secret)
        end

        def generate_token
          token = super

          @redis.with do |conn|
            conn.set("epo_token_#{id}", token.token, ex: token.expires_in, nx: true)
          end

          token
        end
      end
    end
  end
end
