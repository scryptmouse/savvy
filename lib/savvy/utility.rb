module Savvy
  module Utility
    module_function

    # Validate that the provided value is a one-dimensional
    # array of strings that may or may not exist in `ENV`.
    #
    # @param [<String>] vars
    def valid_env_vars?(vars)
      return false unless vars.kind_of?(Array)

      vars.all? do |var|
        valid_env_var? var
      end
    end

    # Validate that the provided var is a string
    # that can be used as a name for environment
    # variables.
    #
    # @param [String] var
    def valid_env_var?(var)
      var.kind_of?(String) && Dux.presentish?(var)
    end

    def valid_url?(url, scheme: nil)
      return false unless url.kind_of?(String) && Dux.presentish?(url)

      if scheme
        return false unless url.start_with?("#{scheme}://")
      end

      return true
    end
  end
end
