require "bundler/setup"
require "stub_env"
require "cleanroom/rspec"

if RUBY_PLATFORM != 'java'
  require 'simplecov'

  SimpleCov.start do
    add_filter "test_object.rb"
    add_filter "spec/support"
  end
end

TEST_ROOT = Bundler.root.join('spec/test_root')

require "savvy"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include StubEnv::Helpers
end
