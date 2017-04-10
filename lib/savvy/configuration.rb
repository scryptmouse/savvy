module Savvy
  # Configuration files that can be contained
  # in an application root directory.
  FILES = %w[
    savvy.rb
    Savvyfile
  ].freeze

  # Shared configuration object for a Savvy-enabled application
  class Configuration
    APP_ENV_VARS = %w[
      RAILS_ENV
      RACK_ENV
    ].freeze

    DEFAULT_REDIS_ENV_VARS = %w[
      REDISTOGO_URL
      REDISCLOUD_URL
      BOXEN_REDIS_URL
      REDIS_URL
    ].freeze

    DEFAULT_REDIS_URL = 'redis://localhost:6379'

    attr_reader :env
    attr_reader :root

    def initialize(root:, env: Savvy.env)
      @root = root
      @env  = env

      @config_file = find_config_file

      @app_name           = root.basename.to_s
      @include_app_env    = false
      @redis_env_vars     = DEFAULT_REDIS_ENV_VARS.dup
      @redis_default_url  = DEFAULT_REDIS_URL
    end

    def setup!
      @app_env = @env[*APP_ENV_VARS]

      load_from_file!
    end

    # @return [String]
    def build_namespace(*parts, separator: ?.)
      [
        app_name,
        ( app_env if include_app_env? ),
        *parts
      ].compact.join(separator)
    end

    def configure
      yield to_dsl if block_given?

      return self
    end

    # @see [Savvy::EnvironmentReader#[]]
    # @return [String]
    def read_from_env(*vars, **options)
      @env[*vars, **options]
    end

    attr_accessor :app_env

    # @overload app_name
    #   Get the current app name
    #   @return [String]
    # @overload app_name=(new_app_name)
    #   @param [String, Symbol] new_app_name
    #   @raise [TypeError] if provided with an invalid app name
    attr_reader :app_name

    def app_name=(new_app_name)
      raise TypeError, "Must provide a string or symbol" unless new_app_name.kind_of?(String) || new_app_name.kind_of?(Symbol)
      raise TypeError, "Must provide a valid app name" unless Dux.presentish?(new_app_name)

      @app_name = new_app_name
    end

    # @!attribute [rw] include_app_env
    # Whether the Rails/Rack env should be included when
    # building namespaces.
    # @return [Boolean]
    attr_reader :include_app_env

    alias_method :include_app_env?, :include_app_env

    def include_app_env=(new_value)
      @include_app_env = !!new_value
    end

    # @!attribute [rw] redis_default_url
    # @return [String]
    attr_reader :redis_default_url

    def redis_default_url=(new_url)
      raise TypeError, "Must be a redis:// url: `#{new_url.inspect}`" unless Savvy::Utility.valid_url?(new_url, scheme: 'redis')

      @redis_default_url = new_url
    end

    # @overload redis_env_vars
    #   Get the current redis env keys
    #   @return [<String>]
    # @overload redis_env_vars=(new_env_keys)
    #   @param [<String>] new_env_keys
    #   @raise [TypeError] if not an array of strings.
    attr_reader :redis_env_vars

    def redis_env_vars=(new_env_keys)
      raise TypeError, "Must be an array of strings" unless Savvy::Utility.valid_env_vars?(new_env_keys)

      @redis_env_vars = new_env_keys
    end

    private

    # @return [Pathname]
    def find_config_file
      Savvy::FILES.each do |file|
        config_path = @root.join(file)

        return config_path if config_path.exist?
      end

      return nil
    end

    # @return [void]
    def load_from_file!
      to_dsl.evaluate_file(@config_file) if @config_file
    end

    # @return [Savvy::ConfigurationDSL]
    def to_dsl
      ConfigurationDSL.new self
    end
  end
end
