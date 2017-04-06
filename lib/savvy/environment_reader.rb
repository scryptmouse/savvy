module Savvy
  class EnvironmentReader
    NONE = Dux.null "Savvy::EnvironmentReader::NONE", purpose: 'When there is no fallback'

    private_constant :NONE

    # @param [#[]] env
    def initialize(env = ENV)
      @env = env
    end

    # Like {#fetch}, but with `raise_error` set to false and `presence` set to true.
    #
    # @param [<String>] names
    # @param [Boolean] presence
    def [](*names, presence: true, raise_error: false, **options)
      options[:raise_error] = raise_error
      options[:presence] = presence

      fetch(*names, **options)
    end

    # @param [<String>] names
    # @param [Object] fallback
    # @param []
    def fetch(*names, fallback: NONE, raise_error: true, presence: false)
      names.flatten!

      names.each do |name|
        if ( presence && has_value?(name) ) || set?(name)
          return @env[name]
        end
      end

      if fallback != NONE
        return fallback
      elsif raise_error
        raise ArgumentError, "No #{'present ' if presence}env value found for #{names.join(', ')}"
      end
    end

    # Check if the environment has a present
    # value set.
    #
    # @param [String] var
    def has_value?(var)
      set?(var) && Dux.presentish?(@env[var])
    end

    # Checks only if the variable is set,
    # not necessarily that it is non-empty.
    #
    # @param [String] var
    def set?(var)
      @env.key?(var)
    end

    private
  end
end
