# frozen_string_literal: true

require "spec_helper"

RSpec.describe Vendorer::GitOperations do
  let(:git_ops) { described_class.new }
  
  describe "#clone" do
    it "clones a repository successfully" do
      repo_url = "https://github.com/ruby/ruby.git"
      destination = File.join(@test_dir, "test_repo")
      
      # This is a mock test - in real scenario, we'd use a test repository
      allow(Open3).to receive(:capture3).and_return(["", "", double(success?: true)])
      
      expect(git_ops.clone(repo_url, destination)).to be true
    end
    
    it "raises error when clone fails" do
      repo_url = "https://github.com/invalid/repo.git"
      destination = File.join(@test_dir, "test_repo")
      
      allow(Open3).to receive(:capture3).and_return(["", "fatal: repository not found", double(success?: false)])
      
      expect { git_ops.clone(repo_url, destination) }.to raise_error(Vendorer::Error)
    end
  end
  
  describe "#has_changes?" do
    it "returns false when there are no changes" do
      repo_path = File.join(@test_dir, "test_repo")
      FileUtils.mkdir_p(repo_path)
      
      git_ops_with_path = described_class.new(repo_path)
      
      allow(Open3).to receive(:capture3).and_return(["", "", double(success?: true)])
      
      expect(git_ops_with_path.has_changes?).to be false
    end
    
    it "returns true when there are changes" do
      repo_path = File.join(@test_dir, "test_repo")
      FileUtils.mkdir_p(repo_path)
      
      git_ops_with_path = described_class.new(repo_path)
      
      allow(Open3).to receive(:capture3).and_return(["M file.rb\n", "", double(success?: true)])
      
      expect(git_ops_with_path.has_changes?).to be true
    end
  end
  
  describe "#status" do
    it "parses git status output correctly" do
      repo_path = File.join(@test_dir, "test_repo")
      FileUtils.mkdir_p(repo_path)
      
      git_ops_with_path = described_class.new(repo_path)
      
      status_output = "M  modified.rb\nA  added.rb\nD  deleted.rb\n?? untracked.rb\n"
      allow(Open3).to receive(:capture3).and_return([status_output, "", double(success?: true)])
      
      status = git_ops_with_path.status
      
      expect(status[:modified]).to include("modified.rb")
      expect(status[:added]).to include("added.rb")
      expect(status[:deleted]).to include("deleted.rb")
      expect(status[:untracked]).to include("untracked.rb")
    end
  end
  
  describe "#current_branch" do
    it "returns the current branch name" do
      repo_path = File.join(@test_dir, "test_repo")
      FileUtils.mkdir_p(repo_path)
      
      git_ops_with_path = described_class.new(repo_path)
      
      allow(Open3).to receive(:capture3).and_return(["main\n", "", double(success?: true)])
      
      expect(git_ops_with_path.current_branch).to eq("main")
    end
  end
  
  describe "#remote_url" do
    it "returns the remote URL" do
      repo_path = File.join(@test_dir, "test_repo")
      FileUtils.mkdir_p(repo_path)
      
      git_ops_with_path = described_class.new(repo_path)
      
      allow(Open3).to receive(:capture3).and_return(
        ["https://github.com/test/repo.git\n", "", double(success?: true)]
      )
      
      expect(git_ops_with_path.remote_url).to eq("https://github.com/test/repo.git")
    end
  end
end
