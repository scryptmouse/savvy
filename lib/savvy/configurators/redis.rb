module Savvy
  module Configurators
    class Redis
      DEFAULT_SEPARATOR = ?:

      PATH_PATTERN = %r{\A/(?<db>\d{1,2})(?:/(?<namespace_prefix>[^/]+))?}

      # This is the namespace portion of a redis URI that
      # is possibly set by the environment and will prefix
      # the Savvy-generated namespace.
      #
      # @return [String, nil]
      attr_reader :namespace_prefix

      # @param [Savvy::Config] config
      def initialize(config: Savvy.config)
        @config = config

        @db = 0
        @namespace_prefix = nil

        parse_url!
      end

      # @param [<String>] parts
      # @param [Boolean] without_namespace return a configuration hash *only* as defined
      # @return [{Symbol => Object}]
      def config_hash(*parts, without_namespace: false)
        check_validity!

        {
          host: @host,
          port: @port,
          db:   @db,
        }.tap do |h|
          ns = without_namespace ? @namespace_prefix : namespace(*parts)

          h[:namespace] = ns unless ns.nil?
        end
      end

      alias to_h config_hash

      # @!attribute [r] db
      # The database number used by redis.
      # @return [Integer]
      def db
        check_validity!

        @db
      end

      # @!attribute [r] host
      # @return [String]
      def host
        check_validity!

        @host
      end

      def namespace(*parts, separator: DEFAULT_SEPARATOR)
        check_validity!

        @config.build_namespace(*parts, prefix: @namespace_prefix, separator: separator)
      end

      # @param [<String>] parts parts to add to the namespace
      # @return [String]
      def namespaced_url(*parts)
        check_validity!

        build_redis_url *parts
      end

      # @!attribute [r] port
      # @return [Integer]
      def port
        check_validity!

        @port
      end

      # The url as configured by the environment (sans namespace)
      #
      # @return [String]
      def url
        check_validity!

        build_redis_url without_namespace: true
      end

      # @return [ConnectionPool]
      def build_connection_pool(*namespace_parts, size: 5, timeout: 5)
        raise Savvy::RedisError, 'Requires connection_pool gem' unless defined?(ConnectionPool)

        ::ConnectionPool.new size: size, timeout: timeout do
          build_connection(*namespace_parts)
        end
      end

      # @return [Redis::Namespace]
      def build_connection(*namespace_parts)
        raise Savvy::RedisError, 'Requires redis-namespace gem' unless defined?(::Redis::Namespace)

        ::Redis::Namespace.new(namespace(*namespace_parts), redis: ::Redis.new(url: url))
      end

      def valid?
        @error.nil?
      end

      private

      # @return [String]
      def build_redis_url(*parts, without_namespace: false)
        ns = without_namespace ? @namespace_prefix : namespace(*parts)

        path = ?/ + [db, ns].compact.join(?/)

        URI.join(@base_uri, path).to_s
      end

      def check_validity!
        raise Savvy::RedisError, "Redis configuration is invalid: #{@error}", caller unless valid?
      end

      # @return [void]
      def parse_url!
        @provided_url = read_url_from_config.freeze

        @parsed_url = URI.parse @provided_url

        @host = @parsed_url.host
        @port = @parsed_url.port

        path_match = PATH_PATTERN.match @parsed_url.path

        if path_match
          captures =
            if path_match.respond_to?(:named_captures)
              path_match.named_captures
            else
              Hash[path_match.names.zip(path_match.captures)]
            end

          @db = Integer(captures['db'])

          @namespace_prefix = captures['namespace_prefix']
        end

        @base_uri = URI::Generic.new 'redis', nil, @host, @port, nil, '', nil, nil, nil
      rescue URI::InvalidURIError => e
        @error = "could not parse redis URL (#{@provided_url})"
      end

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
