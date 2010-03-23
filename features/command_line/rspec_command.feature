Feature: rspec command

  Scenario: with no args and a spec directory
    Given a file named "spec/example_spec.rb" with:
      """
      describe "something" do
        it "does something" do
          #no-op - should pass
        end
      end
      """
    When I run "rspec"
    Then I should see "1 example, 0 failures"
    
  Scenario: with no args and a spec directory
    Given no spec directory
    When I run "rspec"
    Then I should not see "0 examples, 0 failures"
    And I should see "Usage: rspec"
    