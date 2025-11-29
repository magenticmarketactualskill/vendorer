# frozen_string_literal: true

module Vendorer
  class GemManager
    attr_reader :vendor_path, :gemfile_path
    
    def initialize(vendor_path: nil, gemfile_path: nil)
      @vendor_path = vendor_path || Vendorer.vendor_path
      @gemfile_path = gemfile_path || Vendorer.gemfile_path
      @git_ops = GitOperations.new
      @gemfile_editor = GemfileEditor.new(gemfile_path)
    end
    
    def list_vendored_gems
      ensure_vendor_directory_exists
      
      gems = []
      Dir.foreach(vendor_path) do |entry|
        next if entry == "." || entry == ".."
        
        gem_path = File.join(vendor_path, entry)
        next unless File.directory?(gem_path)
        
        # Skip non-gem directories (like cache, bundle, etc.)
        next if ["cache", "bundle", "ruby"].include?(entry)
        
        gem = VendoredGem.new(name: entry, path: gem_path)
        gems << gem if gem.git_repository?
      end
      
      gems
    end
    
    def vendor_gem(name, url, branch: nil)
      ensure_vendor_directory_exists
      
      destination = File.join(vendor_path, name)
      
      if File.exist?(destination)
        raise Error, "Gem '#{name}' already exists at #{destination}"
      end
      
      # Clone the repository
      @git_ops.clone(url, destination, branch: branch)
      
      # Update Gemfile
      relative_path = "./vendor/#{name}"
      @gemfile_editor.add_vendored_gem(name, relative_path)
      
      VendoredGem.new(name: name, path: destination)
    end
    
    def unvendor_gem(name, keep_changes: false)
      gem_path = File.join(vendor_path, name)
      
      unless File.exist?(gem_path)
        raise Error, "Gem '#{name}' not found in vendor directory"
      end
      
      gem = VendoredGem.new(name: name, path: gem_path)
      
      if gem.has_changes? && !keep_changes
        raise Error, "Gem '#{name}' has uncommitted changes. Use --keep-changes to force removal."
      end
      
      # Remove from Gemfile
      @gemfile_editor.remove_vendored_gem(name)
      
      # Remove directory
      FileUtils.rm_rf(gem_path)
      
      true
    end
    
    def push_gem(name, branch: nil, message: nil)
      gem_path = File.join(vendor_path, name)
      
      unless File.exist?(gem_path)
        raise Error, "Gem '#{name}' not found in vendor directory"
      end
      
      gem = VendoredGem.new(name: name, path: gem_path)
      
      unless gem.git_repository?
        raise Error, "Gem '#{name}' is not a git repository"
      end
      
      unless gem.has_changes?
        raise Error, "Gem '#{name}' has no changes to push"
      end
      
      git_ops = GitOperations.new(gem_path)
      
      # Commit changes
      commit_message = message || "Update vendored gem: #{name}"
      git_ops.commit(commit_message)
      
      # Push to remote
      git_ops.push(branch: branch)
      
      true
    end
    
    def gem_status(name)
      gem_path = File.join(vendor_path, name)
      
      unless File.exist?(gem_path)
        raise Error, "Gem '#{name}' not found in vendor directory"
      end
      
      gem = VendoredGem.new(name: name, path: gem_path)
      gem.to_h
    end
    
    private
    
    def ensure_vendor_directory_exists
      FileUtils.mkdir_p(vendor_path) unless File.exist?(vendor_path)
    end
  end
end
