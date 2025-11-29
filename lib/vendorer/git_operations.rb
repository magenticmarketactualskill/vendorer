# frozen_string_literal: true

require "open3"

module Vendorer
  class GitOperations
    attr_reader :path
    
    def initialize(path = nil)
      @path = path
    end
    
    def clone(url, destination, branch: nil)
      cmd = ["git", "clone"]
      cmd += ["--branch", branch] if branch
      cmd += [url, destination]
      
      stdout, stderr, status = Open3.capture3(*cmd)
      
      unless status.success?
        raise Error, "Failed to clone repository: #{stderr}"
      end
      
      true
    end
    
    def remote_url(remote: "origin")
      return nil unless path
      
      stdout, stderr, status = Open3.capture3(
        "git", "-C", path, "config", "--get", "remote.#{remote}.url"
      )
      
      status.success? ? stdout.strip : nil
    end
    
    def current_branch
      return nil unless path
      
      stdout, stderr, status = Open3.capture3(
        "git", "-C", path, "rev-parse", "--abbrev-ref", "HEAD"
      )
      
      status.success? ? stdout.strip : nil
    end
    
    def has_changes?
      return false unless path
      
      stdout, stderr, status = Open3.capture3(
        "git", "-C", path, "status", "--porcelain"
      )
      
      status.success? && !stdout.strip.empty?
    end
    
    def status
      return {} unless path
      
      stdout, stderr, status = Open3.capture3(
        "git", "-C", path, "status", "--porcelain"
      )
      
      return {} unless status.success?
      
      changes = {
        modified: [],
        added: [],
        deleted: [],
        untracked: []
      }
      
      stdout.each_line do |line|
        status_code = line[0..1]
        file = line[3..-1].strip
        
        case status_code.strip
        when "M", "MM"
          changes[:modified] << file
        when "A", "AM"
          changes[:added] << file
        when "D"
          changes[:deleted] << file
        when "??"
          changes[:untracked] << file
        end
      end
      
      changes
    end
    
    def commit(message)
      return false unless path
      
      # Stage all changes
      stdout, stderr, status = Open3.capture3(
        "git", "-C", path, "add", "-A"
      )
      
      unless status.success?
        raise Error, "Failed to stage changes: #{stderr}"
      end
      
      # Commit
      stdout, stderr, status = Open3.capture3(
        "git", "-C", path, "commit", "-m", message
      )
      
      unless status.success?
        raise Error, "Failed to commit changes: #{stderr}"
      end
      
      true
    end
    
    def push(branch: nil, remote: "origin")
      return false unless path
      
      target_branch = branch || current_branch
      
      stdout, stderr, status = Open3.capture3(
        "git", "-C", path, "push", remote, target_branch
      )
      
      unless status.success?
        raise Error, "Failed to push changes: #{stderr}"
      end
      
      true
    end
    
    def create_branch(branch_name, checkout: true)
      return false unless path
      
      cmd = ["git", "-C", path, "checkout", "-b", branch_name]
      cmd = ["git", "-C", path, "branch", branch_name] unless checkout
      
      stdout, stderr, status = Open3.capture3(*cmd)
      
      unless status.success?
        raise Error, "Failed to create branch: #{stderr}"
      end
      
      true
    end
    
    def fetch(remote: "origin")
      return false unless path
      
      stdout, stderr, status = Open3.capture3(
        "git", "-C", path, "fetch", remote
      )
      
      unless status.success?
        raise Error, "Failed to fetch from remote: #{stderr}"
      end
      
      true
    end
  end
end
