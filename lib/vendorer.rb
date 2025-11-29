# frozen_string_literal: true

require_relative "vendorer/version"
require_relative "vendorer/cli"
require_relative "vendorer/gem_manager"
require_relative "vendorer/git_operations"
require_relative "vendorer/gemfile_editor"
require_relative "vendorer/vendored_gem"

module Vendorer
  class Error < StandardError; end
  
  class << self
    attr_accessor :vendor_path, :gemfile_path
    
    def configure
      yield self if block_given?
    end
    
    def vendor_path
      @vendor_path ||= File.join(Dir.pwd, "vendor")
    end
    
    def gemfile_path
      @gemfile_path ||= File.join(Dir.pwd, "Gemfile")
    end
  end
end
