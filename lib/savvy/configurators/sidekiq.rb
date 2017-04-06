require 'savvy/configurators/redis'

module Savvy
  module Configurators
    class Sidekiq
      def initialize(config: Savvy.config, redis: Savvy.redis)
        @config = config
        @redis = redis
      end

      # @return [Hash]
      def redis_options
        {
          url:        @redis.url,
          namespace:  @redis.namespace('sidekiq')
        }
      end
    end
  end

  class << self
    # @!attribute [r] sidekiq
    # @return [Savvy::Configurators::Sidekiq]
    def sidekiq
      @sidekiq ||= Savvy::Configurators::Sidekiq.new
    end
  end
end
