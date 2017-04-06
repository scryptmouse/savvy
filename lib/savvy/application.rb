require 'commander'
require 'erb'

module Savvy
  class Application
    include Commander::Methods

    SAVVYFILE_TEMPLATE = File.join(__dir__, 'templates', 'Savvyfile.rb.erb')

    attr_reader :config
    attr_reader :savvyfile

    def initialize
      @config = Savvy.config
      @savvyfile = Savvy.config.root.join('Savvyfile')

      @config.setup!
    end

    def run
      program :name, 'savvy'
      program :version, Savvy::VERSION
      program :description, 'Savvy file generator'

      command :init do |c|
        c.syntax = 'savvy init'
        c.description = 'Initialize a Savvyfile'
        c.action do
          if savvyfile.exist?
            puts "! #{savvyfile} exists"

            unless agree("Do you want to overwrite? ")
              puts "Not overwriting"

              exit
            end
          end

          contents = savvyfile_contents

          puts "Writing to #{savvyfile}"

          savvyfile.open('w+') do |f|
            f.write contents
          end
        end
      end

      run!
    end

    def savvyfile_contents
      app_name = config.app_name = ask 'What is the name of your app? ' do |q|
        q.default = config.app_name
      end

      ERB.new(File.read(SAVVYFILE_TEMPLATE)).result(binding)
    end
  end
end
