require 'pathname'
require 'uri'

require 'cleanroom'
require 'dux'

require 'savvy/version'

require 'savvy/configuration'
require 'savvy/configuration_dsl'
require 'savvy/environment_reader'
require 'savvy/root_finder'
require 'savvy/utility'

require 'savvy/configurators/all'

module Savvy
  class << self
    # @!attribute [r] config
    # @return [Savvy::Configuration]
    def config
      @@config
    end

    # @!attribute [r] env
    # @return [Savvy::EnvironmentReader]
    def env
      @@env
    end

    # @return [void]
    def initialize!
      @@config.setup!
    end

    # @param [<String>] parts
    # @return [String]
    def namespace(*parts, separator: ?.)
      @@config.build_namespace(*parts, separator: separator)
    end

    # @return [Pathname]
    def root
      @@config.root
    end

    private

    # @return [Pathname]
    def figure_out_root!
      Savvy::RootFinder.call Dir.pwd
    end
  end

  @@env = Savvy::EnvironmentReader.new
  @@config = Savvy::Configuration.new root: figure_out_root!, env: env
end
