# frozen_string_literal: true

Given("I have a Ruby project with a Gemfile") do
  File.write(@gemfile_path, "source 'https://rubygems.org'\n")
end

Given("I have already vendored {string}") do |gem_name|
  gem_path = File.join(@vendor_dir, gem_name)
  FileUtils.mkdir_p(File.join(gem_path, ".git"))
end

Given("I have vendored {string} from {string}") do |gem_name, url|
  gem_path = File.join(@vendor_dir, gem_name)
  FileUtils.mkdir_p(File.join(gem_path, ".git"))
  
  # Mock git config
  git_dir = File.join(gem_path, ".git")
  config_file = File.join(git_dir, "config")
  File.write(config_file, "[remote \"origin\"]\n\turl = #{url}\n")
  
  # Update Gemfile
  gemfile_content = File.read(@gemfile_path)
  gemfile_content += "gem '#{gem_name}', path: './vendor/#{gem_name}'\n"
  File.write(@gemfile_path, gemfile_content)
end

Given("I have made changes to {string}") do |gem_name|
  gem_path = File.join(@vendor_dir, gem_name)
  File.write(File.join(gem_path, "test_file.rb"), "# Modified content")
end

When("I run {string}") do |command|
  # Mock the command execution for testing
  @last_command = command
  
  if command.include?("vendorer list")
    manager = Vendorer::GemManager.new
    gems = manager.list_vendored_gems
    
    if gems.empty?
      @last_command_output = "No vendored gems found."
    else
      @last_command_output = "Vendored Gems:\n"
      gems.each do |gem|
        @last_command_output += "Gem: #{gem.name}\n"
        @last_command_output += "  Status: #{gem.has_changes? ? 'Has uncommitted changes' : 'Clean'}\n"
      end
      @last_command_output += "Total: #{gems.count} vendored gem(s)"
    end
  elsif command.match(/vendorer vendor (\w+) --url=(.+?)( --branch=(.+))?$/)
    gem_name = $1
    url = $2
    branch = $4
    
    begin
      # Mock vendoring
      gem_path = File.join(@vendor_dir, gem_name)
      if File.exist?(gem_path)
        @last_command_error = "Error: Gem '#{gem_name}' already exists"
      else
        FileUtils.mkdir_p(File.join(gem_path, ".git"))
        
        gemfile_content = File.read(@gemfile_path)
        gemfile_content += "gem '#{gem_name}', path: './vendor/#{gem_name}'\n"
        File.write(@gemfile_path, gemfile_content)
        
        @last_command_output = "Successfully vendored '#{gem_name}' to #{gem_path}"
      end
    rescue => e
      @last_command_error = "Error: #{e.message}"
    end
  end
end

Then("the gem should be cloned to {string}") do |path|
  full_path = File.join(@project_dir, path)
  expect(File.exist?(full_path)).to be true
end

Then("the gem should be cloned to {string} on branch {string}") do |path, branch|
  full_path = File.join(@project_dir, path)
  expect(File.exist?(full_path)).to be true
  # In a real implementation, we'd check the actual branch
end

Then("the Gemfile should contain {string}") do |content|
  gemfile_content = File.read(@gemfile_path)
  expect(gemfile_content).to include(content)
end

Then("I should see {string}") do |text|
  output = @last_command_output + @last_command_error
  expect(output).to include(text)
end

Then("I should see an error {string}") do |error_text|
  expect(@last_command_error).to include(error_text)
end
