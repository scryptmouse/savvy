module Savvy
  # Configuration DSL for a {Savvy::Configuration}.
  #
  # Keeps the methods separate / cleaner.
  #
  # @api private
  class ConfigurationDSL
    include Cleanroom

    def initialize(config)
      @config = config
    end

    def app_name(value)
      @config.app_name = value
    end

    expose :app_name

    def include_app_env_in_namespaces!
      @config.include_app_env = true
    end

    expose :include_app_env_in_namespaces!

    def redis_default_url(url)
      @config.redis_default_url = url
    end

    expose :redis_default_url

    def redis_env_vars(*vars)
      @config.redis_env_vars = vars.flatten
    end

    expose :redis_env_vars
  end
end
