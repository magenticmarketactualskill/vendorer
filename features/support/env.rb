# frozen_string_literal: true

require "vendorer"
require "fileutils"
require "tmpdir"

Before do
  @test_dir = Dir.mktmpdir("vendorer_cucumber")
  @project_dir = File.join(@test_dir, "project")
  @vendor_dir = File.join(@project_dir, "vendor")
  @gemfile_path = File.join(@project_dir, "Gemfile")
  
  FileUtils.mkdir_p(@project_dir)
  
  Vendorer.configure do |config|
    config.vendor_path = @vendor_dir
    config.gemfile_path = @gemfile_path
  end
  
  @last_command_output = ""
  @last_command_error = ""
end

After do
  FileUtils.rm_rf(@test_dir) if @test_dir && File.exist?(@test_dir)
end
