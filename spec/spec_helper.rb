# frozen_string_literal: true

require "vendorer"
require "fileutils"
require "tmpdir"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  
  # Create a temporary directory for testing
  config.before(:each) do
    @test_dir = Dir.mktmpdir("vendorer_test")
    @vendor_path = File.join(@test_dir, "vendor")
    @gemfile_path = File.join(@test_dir, "Gemfile")
    
    # Create a basic Gemfile
    File.write(@gemfile_path, "source 'https://rubygems.org'\n")
    
    # Configure Vendorer paths
    Vendorer.configure do |c|
      c.vendor_path = @vendor_path
      c.gemfile_path = @gemfile_path
    end
  end
  
  config.after(:each) do
    FileUtils.rm_rf(@test_dir) if @test_dir && File.exist?(@test_dir)
  end
end
