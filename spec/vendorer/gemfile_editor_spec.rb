# frozen_string_literal: true

require "spec_helper"

RSpec.describe Vendorer::GemfileEditor do
  let(:editor) { described_class.new(@gemfile_path) }
  
  describe "#add_vendored_gem" do
    it "adds a new vendored gem to Gemfile" do
      editor.add_vendored_gem("test_gem", "./vendor/test_gem")
      
      content = File.read(@gemfile_path)
      expect(content).to include("gem 'test_gem', path: './vendor/test_gem'")
    end
    
    it "replaces existing gem declaration" do
      File.write(@gemfile_path, "source 'https://rubygems.org'\ngem 'test_gem', '1.0.0'\n")
      
      editor.add_vendored_gem("test_gem", "./vendor/test_gem")
      
      content = File.read(@gemfile_path)
      expect(content).to include("gem 'test_gem', path: './vendor/test_gem'")
      expect(content).not_to include("gem 'test_gem', '1.0.0'")
    end
  end
  
  describe "#remove_vendored_gem" do
    it "removes a vendored gem from Gemfile" do
      File.write(@gemfile_path, "source 'https://rubygems.org'\ngem 'test_gem', path: './vendor/test_gem'\n")
      
      editor.remove_vendored_gem("test_gem")
      
      content = File.read(@gemfile_path)
      expect(content).not_to include("gem 'test_gem'")
    end
  end
  
  describe "#has_gem?" do
    it "returns true when gem exists" do
      File.write(@gemfile_path, "source 'https://rubygems.org'\ngem 'test_gem'\n")
      
      expect(editor.has_gem?("test_gem")).to be true
    end
    
    it "returns false when gem does not exist" do
      expect(editor.has_gem?("nonexistent_gem")).to be false
    end
  end
  
  describe "#gem_source" do
    it "detects path-based gem" do
      File.write(@gemfile_path, "source 'https://rubygems.org'\ngem 'test_gem', path: './vendor/test_gem'\n")
      
      source = editor.gem_source("test_gem")
      expect(source[:type]).to eq(:path)
      expect(source[:value]).to eq("./vendor/test_gem")
    end
    
    it "detects git-based gem" do
      File.write(@gemfile_path, "source 'https://rubygems.org'\ngem 'test_gem', git: 'https://github.com/test/gem.git'\n")
      
      source = editor.gem_source("test_gem")
      expect(source[:type]).to eq(:git)
      expect(source[:value]).to eq("https://github.com/test/gem.git")
    end
    
    it "detects version-based gem" do
      File.write(@gemfile_path, "source 'https://rubygems.org'\ngem 'test_gem', '1.0.0'\n")
      
      source = editor.gem_source("test_gem")
      expect(source[:type]).to eq(:version)
      expect(source[:value]).to eq("1.0.0")
    end
    
    it "detects simple gem declaration" do
      File.write(@gemfile_path, "source 'https://rubygems.org'\ngem 'test_gem'\n")
      
      source = editor.gem_source("test_gem")
      expect(source[:type]).to eq(:simple)
    end
  end
  
  describe "#restore_gem_from_rubygems" do
    it "restores gem to standard declaration" do
      File.write(@gemfile_path, "source 'https://rubygems.org'\ngem 'test_gem', path: './vendor/test_gem'\n")
      
      editor.restore_gem_from_rubygems("test_gem", version: "1.0.0")
      
      content = File.read(@gemfile_path)
      expect(content).to include("gem 'test_gem', '1.0.0'")
      expect(content).not_to include("path:")
    end
  end
end
