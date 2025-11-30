# frozen_string_literal: true

require "thor"
require "fileutils"

module Vendorer
  class CLI < Thor
    def self.exit_on_failure?
      true
    end
    
    desc "list", "List all vendored gems"
    def list
      manager = GemManager.new
      gems = manager.list_vendored_gems
      
      if gems.empty?
        say "No vendored gems found.", :yellow
        return
      end
      
      say "\nVendored Gems:", :green
      say "=" * 80
      
      gems.each do |gem|
        say "\nGem: #{gem.name}", :cyan
        say "  Path: #{gem.path}"
        say "  Remote: #{gem.remote_url || 'N/A'}"
        say "  Branch: #{gem.branch || 'N/A'}"
        
        if gem.has_changes?
          say "  Status: Has uncommitted changes", :yellow
          
          status = gem.status
          say "    Modified: #{status[:modified].count}" if status[:modified].any?
          say "    Added: #{status[:added].count}" if status[:added].any?
          say "    Deleted: #{status[:deleted].count}" if status[:deleted].any?
          say "    Untracked: #{status[:untracked].count}" if status[:untracked].any?
        else
          say "  Status: Clean", :green
        end
      end
      
      say "\n" + "=" * 80
      say "Total: #{gems.count} vendored gem(s)", :green
    end
    
    desc "vendor GEM_NAME", "Vendor a gem from GitHub"
    method_option :url, type: :string, required: true, desc: "GitHub repository URL"
    method_option :branch, type: :string, desc: "Branch or tag to checkout"
    def vendor(name)
      url = options[:url]
      branch = options[:branch]
      
      say "Vendoring gem '#{name}' from #{url}...", :green
      
      manager = GemManager.new
      gem = manager.vendor_gem(name, url, branch: branch)
      
      say "Successfully vendored '#{name}' to #{gem.path}", :green
      say "Gemfile has been updated.", :green
      say "\nRun 'bundle install' to complete the setup.", :yellow
    rescue Error => e
      say "Error: #{e.message}", :red
      exit 1
    end
    
    desc "unvendor GEM_NAME", "Remove a vendored gem"
    method_option :keep_changes, type: :boolean, default: false, desc: "Keep local changes (force removal)"
    def unvendor(name)
      manager = GemManager.new
      
      say "Unvendoring gem '#{name}'...", :green
      
      manager.unvendor_gem(name, keep_changes: options[:keep_changes])
      
      say "Successfully removed '#{name}' from vendor directory", :green
      say "Gemfile has been updated.", :green
      say "\nRun 'bundle install' to update dependencies.", :yellow
    rescue Error => e
      say "Error: #{e.message}", :red
      exit 1
    end
    
    desc "push GEM_NAME", "Push changes in a vendored gem to remote"
    method_option :branch, type: :string, desc: "Branch to push to (defaults to current branch)"
    method_option :message, type: :string, aliases: "-m", desc: "Commit message"
    def push(name)
      manager = GemManager.new
      
      say "Pushing changes for '#{name}'...", :green
      
      manager.push_gem(name, branch: options[:branch], message: options[:message])
      
      say "Successfully pushed changes for '#{name}'", :green
    rescue Error => e
      say "Error: #{e.message}", :red
      exit 1
    end
    
    desc "status [GEM_NAME]", "Show status of vendored gems"
    def status(name = nil)
      manager = GemManager.new
      
      if name
        # Show status for specific gem
        show_gem_status(manager, name)
      else
        # Show status for all gems
        gems = manager.list_vendored_gems
        
        if gems.empty?
          say "No vendored gems found.", :yellow
          return
        end
        
        gems.each do |gem|
          show_gem_status(manager, gem.name)
          say ""
        end
      end
    rescue Error => e
      say "Error: #{e.message}", :red
      exit 1
    end
    
    desc "update", "Update all vendored gems with changes (git add, commit, push)"
    method_option :message, type: :string, aliases: "-m", desc: "Commit message (default: 'Update vendored gems')"
    method_option :branch, type: :string, desc: "Branch to push to (defaults to current branch for each gem)"
    def update
      manager = GemManager.new
      gems = manager.list_vendored_gems
      
      if gems.empty?
        say "No vendored gems found.", :yellow
        return
      end
      
      gems_with_changes = gems.select(&:has_changes?)
      
      if gems_with_changes.empty?
        say "No vendored gems have uncommitted changes.", :green
        return
      end
      
      say "\nFound #{gems_with_changes.count} gem(s) with changes:", :green
      gems_with_changes.each do |gem|
        say "  - #{gem.name}", :cyan
      end
      say ""
      
      commit_message = options[:message] || "Update vendored gems"
      
      gems_with_changes.each do |gem|
        say "Processing #{gem.name}...", :cyan
        
        begin
          manager.push_gem(gem.name, branch: options[:branch], message: commit_message)
          say "  ✓ Successfully pushed #{gem.name}", :green
        rescue Error => e
          say "  ✗ Failed to push #{gem.name}: #{e.message}", :red
        end
      end
      
      say "\nUpdate complete!", :green
    rescue Error => e
      say "Error: #{e.message}", :red
      exit 1
    end
    
    desc "version", "Show vendorer version"
    def version
      say "Vendorer version #{Vendorer::VERSION}", :green
    end
    
    private
    
    def show_gem_status(manager, name)
      status = manager.gem_status(name)
      
      say "Gem: #{status[:name]}", :cyan
      say "  Path: #{status[:path]}"
      say "  Remote: #{status[:remote_url] || 'N/A'}"
      say "  Branch: #{status[:branch] || 'N/A'}"
      
      if status[:has_changes]
        say "  Status: Has uncommitted changes", :yellow
      else
        say "  Status: Clean", :green
      end
    end
  end
end
