# frozen_string_literal: true

module Vendorer
  class VendoredGem
    attr_reader :name, :path, :remote_url, :branch
    
    def initialize(name:, path:)
      @name = name
      @path = path
      @git_ops = GitOperations.new(path)
    end
    
    def exists?
      File.directory?(path)
    end
    
    def git_repository?
      File.directory?(File.join(path, ".git"))
    end
    
    def remote_url
      return nil unless git_repository?
      @git_ops.remote_url
    end
    
    def branch
      return nil unless git_repository?
      @git_ops.current_branch
    end
    
    def has_changes?
      return false unless git_repository?
      @git_ops.has_changes?
    end
    
    def status
      return {} unless git_repository?
      @git_ops.status
    end
    
    def to_h
      {
        name: name,
        path: path,
        remote_url: remote_url,
        branch: branch,
        has_changes: has_changes?,
        git_repository: git_repository?
      }
    end
  end
end
