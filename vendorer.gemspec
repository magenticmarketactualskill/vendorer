# frozen_string_literal: true

require_relative "lib/vendorer/version"

Gem::Specification.new do |spec|
  spec.name = "vendorer"
  spec.version = Vendorer::VERSION
  spec.authors = ["Vendorer Team"]
  spec.email = ["team@vendorer.dev"]

  spec.summary = "Manage vendored Ruby gems in your project"
  spec.description = "A tool for managing Ruby gems that are vendored into your project's ./vendor directory. Handles cloning from GitHub, tracking changes, and pushing updates back."
  spec.homepage = "https://github.com/vendorer/vendorer"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/vendorer/vendorer"
  spec.metadata["changelog_uri"] = "https://github.com/vendorer/vendorer/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "thor", "~> 1.3"
  spec.add_dependency "bundler", ">= 2.0"

  # Development dependencies
  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "cucumber", "~> 9.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
end
