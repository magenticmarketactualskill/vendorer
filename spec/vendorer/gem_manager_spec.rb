# frozen_string_literal: true

require "spec_helper"

RSpec.describe Vendorer::GemManager do
  let(:manager) { described_class.new(vendor_path: @vendor_path, gemfile_path: @gemfile_path) }
  
  describe "#list_vendored_gems" do
    it "returns empty array when no gems are vendored" do
      gems = manager.list_vendored_gems
      expect(gems).to be_empty
    end
    
    it "lists vendored gems with git repositories" do
      # Create a mock vendored gem directory with .git
      gem_path = File.join(@vendor_path, "test_gem")
      FileUtils.mkdir_p(File.join(gem_path, ".git"))
      
      gems = manager.list_vendored_gems
      expect(gems.count).to eq(1)
      expect(gems.first.name).to eq("test_gem")
    end
    
    it "skips non-git directories" do
      # Create directories without .git
      FileUtils.mkdir_p(File.join(@vendor_path, "cache"))
      FileUtils.mkdir_p(File.join(@vendor_path, "bundle"))
      
      gems = manager.list_vendored_gems
      expect(gems).to be_empty
    end
  end
  
  describe "#vendor_gem" do
    it "vendors a gem successfully" do
      allow_any_instance_of(Vendorer::GitOperations).to receive(:clone).and_return(true)
      
      gem = manager.vendor_gem("test_gem", "https://github.com/test/gem.git")
      
      expect(gem).to be_a(Vendorer::VendoredGem)
      expect(gem.name).to eq("test_gem")
      
      content = File.read(@gemfile_path)
      expect(content).to include("gem 'test_gem', path: './vendor/test_gem'")
    end
    
    it "raises error when gem already exists" do
      FileUtils.mkdir_p(File.join(@vendor_path, "test_gem"))
      
      expect {
        manager.vendor_gem("test_gem", "https://github.com/test/gem.git")
      }.to raise_error(Vendorer::Error, /already exists/)
    end
  end
  
  describe "#unvendor_gem" do
    it "removes a vendored gem" do
      gem_path = File.join(@vendor_path, "test_gem")
      FileUtils.mkdir_p(File.join(gem_path, ".git"))
      File.write(@gemfile_path, "source 'https://rubygems.org'\ngem 'test_gem', path: './vendor/test_gem'\n")
      
      allow_any_instance_of(Vendorer::VendoredGem).to receive(:has_changes?).and_return(false)
      
      result = manager.unvendor_gem("test_gem")
      
      expect(result).to be true
      expect(File.exist?(gem_path)).to be false
      
      content = File.read(@gemfile_path)
      expect(content).not_to include("test_gem")
    end
    
    it "raises error when gem has uncommitted changes" do
      gem_path = File.join(@vendor_path, "test_gem")
      FileUtils.mkdir_p(File.join(gem_path, ".git"))
      
      allow_any_instance_of(Vendorer::VendoredGem).to receive(:has_changes?).and_return(true)
      
      expect {
        manager.unvendor_gem("test_gem")
      }.to raise_error(Vendorer::Error, /uncommitted changes/)
    end
    
    it "removes gem with changes when keep_changes is true" do
      gem_path = File.join(@vendor_path, "test_gem")
      FileUtils.mkdir_p(File.join(gem_path, ".git"))
      File.write(@gemfile_path, "source 'https://rubygems.org'\ngem 'test_gem', path: './vendor/test_gem'\n")
      
      allow_any_instance_of(Vendorer::VendoredGem).to receive(:has_changes?).and_return(true)
      
      result = manager.unvendor_gem("test_gem", keep_changes: true)
      
      expect(result).to be true
      expect(File.exist?(gem_path)).to be false
    end
  end
  
  describe "#push_gem" do
    it "pushes changes successfully" do
      gem_path = File.join(@vendor_path, "test_gem")
      FileUtils.mkdir_p(File.join(gem_path, ".git"))
      
      allow_any_instance_of(Vendorer::VendoredGem).to receive(:has_changes?).and_return(true)
      allow_any_instance_of(Vendorer::GitOperations).to receive(:commit).and_return(true)
      allow_any_instance_of(Vendorer::GitOperations).to receive(:push).and_return(true)
      
      result = manager.push_gem("test_gem", message: "Test commit")
      
      expect(result).to be true
    end
    
    it "raises error when gem has no changes" do
      gem_path = File.join(@vendor_path, "test_gem")
      FileUtils.mkdir_p(File.join(gem_path, ".git"))
      
      allow_any_instance_of(Vendorer::VendoredGem).to receive(:has_changes?).and_return(false)
      
      expect {
        manager.push_gem("test_gem")
      }.to raise_error(Vendorer::Error, /no changes/)
    end
  end
  
  describe "#gem_status" do
    it "returns status hash for a gem" do
      gem_path = File.join(@vendor_path, "test_gem")
      FileUtils.mkdir_p(File.join(gem_path, ".git"))
      
      status = manager.gem_status("test_gem")
      
      expect(status).to be_a(Hash)
      expect(status[:name]).to eq("test_gem")
      expect(status[:path]).to eq(gem_path)
    end
  end
end
