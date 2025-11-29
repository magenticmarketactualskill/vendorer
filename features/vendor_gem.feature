Feature: Vendor a Ruby gem
  As a Ruby developer
  I want to vendor a gem from GitHub
  So that I can make local modifications

  Scenario: Vendor a gem successfully
    Given I have a Ruby project with a Gemfile
    When I run "vendorer vendor test_gem --url=https://github.com/test/gem.git"
    Then the gem should be cloned to "./vendor/test_gem"
    And the Gemfile should contain "gem 'test_gem', path: './vendor/test_gem'"
    And I should see "Successfully vendored 'test_gem'"

  Scenario: Vendor a gem with specific branch
    Given I have a Ruby project with a Gemfile
    When I run "vendorer vendor test_gem --url=https://github.com/test/gem.git --branch=develop"
    Then the gem should be cloned to "./vendor/test_gem" on branch "develop"
    And the Gemfile should contain "gem 'test_gem', path: './vendor/test_gem'"

  Scenario: Attempt to vendor an already vendored gem
    Given I have a Ruby project with a Gemfile
    And I have already vendored "test_gem"
    When I run "vendorer vendor test_gem --url=https://github.com/test/gem.git"
    Then I should see an error "already exists"
