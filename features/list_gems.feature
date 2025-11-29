Feature: List vendored gems
  As a Ruby developer
  I want to see all vendored gems
  So that I can track what's in my vendor directory

  Scenario: List vendored gems when none exist
    Given I have a Ruby project with a Gemfile
    When I run "vendorer list"
    Then I should see "No vendored gems found"

  Scenario: List vendored gems
    Given I have a Ruby project with a Gemfile
    And I have vendored "gem_one" from "https://github.com/test/one.git"
    And I have vendored "gem_two" from "https://github.com/test/two.git"
    When I run "vendorer list"
    Then I should see "gem_one"
    And I should see "gem_two"
    And I should see "Total: 2 vendored gem(s)"

  Scenario: List shows gems with changes
    Given I have a Ruby project with a Gemfile
    And I have vendored "test_gem" from "https://github.com/test/gem.git"
    And I have made changes to "test_gem"
    When I run "vendorer list"
    Then I should see "test_gem"
    And I should see "Has uncommitted changes"
