module Savvy
  module Configurators
    class Redis
      DEFAULT_SEPARATOR = ?:

      # @!attribute [r] url
      # @return [String]
      attr_reader :url

      # @param [Savvy::Config] config
      def initialize(config: Savvy.config)
        @config = config
        @url = read_url_from_config
      end

      def namespace(*parts, separator: DEFAULT_SEPARATOR)
        @config.build_namespace(*parts, separator: separator)
      end

      def namespaced_url(*parts)
        "#{url}/#{namespace(*parts)}"
      end

      # @return [ConnectionPool]
      def build_connection_pool(*namespace_parts, size: 5, timeout: 5)
        raise 'Requires connection_pool gem' unless defined?(ConnectionPool)

        ::ConnectionPool.new size: size, timeout: timeout do
          build_connection(*namespace_parts)
        end
      end

      def build_connection(*namespace_parts)
        raise 'Requires redis-namespace gem' unless defined?(::Redis::Namespace)

        ::Redis::Namespace.new(namespace(*namespace_parts), redis: ::Redis.new(url: url))
      end

      private

      def read_url_from_config
        @config.read_from_env *@config.redis_env_vars, fallback: @config.redis_default_url
      end
    end
  end

  class << self
    # @!attribute [r] redis
    # @return [Savvy::Configurators::Redis]
    def redis
      @redis ||= Savvy::Configurators::Redis.new
    end
  end
end
