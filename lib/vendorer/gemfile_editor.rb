# frozen_string_literal: true

module Vendorer
  class GemfileEditor
    attr_reader :gemfile_path
    
    def initialize(gemfile_path = nil)
      @gemfile_path = gemfile_path || Vendorer.gemfile_path
    end
    
    def add_vendored_gem(name, path)
      unless File.exist?(gemfile_path)
        raise Error, "Gemfile not found at #{gemfile_path}"
      end
      
      content = File.read(gemfile_path)
      
      # Check if gem already exists
      if has_gem?(name)
        # Replace existing gem declaration
        content = replace_gem_declaration(content, name, path)
      else
        # Add new gem declaration
        content = add_gem_declaration(content, name, path)
      end
      
      File.write(gemfile_path, content)
      true
    end
    
    def remove_vendored_gem(name)
      unless File.exist?(gemfile_path)
        raise Error, "Gemfile not found at #{gemfile_path}"
      end
      
      content = File.read(gemfile_path)
      
      # Remove the vendored gem line
      content = content.gsub(/^gem\s+['"]#{Regexp.escape(name)}['"]\s*,\s*path:\s*['"][^'"]+['"]\s*\n?/, "")
      
      File.write(gemfile_path, content)
      true
    end
    
    def has_gem?(name)
      return false unless File.exist?(gemfile_path)
      
      content = File.read(gemfile_path)
      content.match?(/gem\s+['"]#{Regexp.escape(name)}['"]/)
    end
    
    def gem_source(name)
      return nil unless File.exist?(gemfile_path)
      
      content = File.read(gemfile_path)
      
      # Check for path-based gem
      if content =~ /gem\s+['"]#{Regexp.escape(name)}['"]\s*,\s*path:\s*['"]([^'"]+)['"]/
        return { type: :path, value: $1 }
      end
      
      # Check for git-based gem
      if content =~ /gem\s+['"]#{Regexp.escape(name)}['"]\s*,\s*git:\s*['"]([^'"]+)['"]/
        return { type: :git, value: $1 }
      end
      
      # Check for version-based gem
      if content =~ /gem\s+['"]#{Regexp.escape(name)}['"]\s*,\s*['"]([^'"]+)['"]/
        return { type: :version, value: $1 }
      end
      
      # Simple gem declaration without version
      if content =~ /gem\s+['"]#{Regexp.escape(name)}['"]/
        return { type: :simple, value: nil }
      end
      
      nil
    end
    
    def restore_gem_from_rubygems(name, version: nil)
      unless File.exist?(gemfile_path)
        raise Error, "Gemfile not found at #{gemfile_path}"
      end
      
      content = File.read(gemfile_path)
      
      # Remove vendored gem line
      content = content.gsub(/^gem\s+['"]#{Regexp.escape(name)}['"]\s*,\s*path:\s*['"][^'"]+['"]\s*\n?/, "")
      
      # Add standard gem declaration
      new_declaration = if version
        "gem '#{name}', '#{version}'\n"
      else
        "gem '#{name}'\n"
      end
      
      # Add at the end of the file
      content += "\n" unless content.end_with?("\n")
      content += new_declaration
      
      File.write(gemfile_path, content)
      true
    end
    
    private
    
    def replace_gem_declaration(content, name, path)
      # Replace any existing gem declaration with the vendored version
      content.gsub(
        /^gem\s+['"]#{Regexp.escape(name)}['"].*$/,
        "gem '#{name}', path: '#{path}'"
      )
    end
    
    def add_gem_declaration(content, name, path)
      # Add the gem declaration at the end
      content += "\n" unless content.end_with?("\n")
      content += "gem '#{name}', path: '#{path}'\n"
      content
    end
  end
end
