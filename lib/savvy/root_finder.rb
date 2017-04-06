module Savvy
  module RootFinder
    module_function

    # Something that, given a directory possessing such a file,
    # would make it look like a potential root directory.
    ROOT_FILES = [
      *Savvy::FILES,
      'Gemfile'
    ].freeze

    def find_potential_root_from(origin = Dir.pwd)
      start_root = Pathname.new(origin)

      start_root.ascend do |path|
        if looks_like_a_root_directory?(path)
          return path
        end
      end

      raise ArgumentError, "Could not find root from #{origin}"
    end

    def looks_like_a_root_directory?(path)
      ROOT_FILES.any? do |filename|
        path.join(filename).exist?
      end
    end

    class << self
      # @param [String, Pathname] origin
      # @return [Pathname]
      def call(origin = Dir.pwd)
        if defined?(Rails) && Rails.root
          Rails.root
        elsif defined?(Bundler) && Bundler.root
          Bundler.root
        else
          find_potential_root_from(origin)
        end
      end
    end
  end
end
