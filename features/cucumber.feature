Feature: The cucumber command

  Background:
    Given a file named "config/cucumber.yml" with:
    """
    default: features
    rerun: features
    """

  Scenario: Run a single feature
    Given a file named "features/single.feature" with:
    """
    Feature: Running a single feature
      Scenario: A single scenario
    """

    When I run `geordi cucumber features/single.feature`
    Then the output should contain "# Running features"
      And the output should contain "> Only: features/single.feature"
    But the output should not contain "parallel"


  Scenario: Multiple features are run in parallel
    Given a file named "features/one.feature" with:
    """
    Feature: One
      Scenario: One
    """
    And a file named "features/two.feature" with:
    """
    Feature: Two
      Scenario: Two
    """

    When I run `geordi cucumber`
    Then the output should contain "# Running features"
      And the output should contain "> All features in features/"
      And the output should contain "> Using parallel_tests"


  Scenario: Rerunning tests until they pass
    Given a file named "features/step_definitions/test_steps.rb" with:
    """
    Given /^this test fails$/ do
      raise
    end
    """
    And a file named "features/failing.feature" with:
    """
    Feature: Failing feature
      Scenario: Failing scenario
        And this test fails
    """

    When I run `geordi cucumber --rerun=2`
    Then the output should contain "# Running features"
      And the output should contain "# Rerun #1 of 2"
      And the output should contain "# Rerun #2 of 2"
      And the output should contain "Using the rerun profile"
      And the exit status should be 1


  Scenario: Running all features in a given subfolder
    Given a file named "features/sub/one.feature" with:
    """
    Feature: Testfeature
    """
    And a file named "features/sub/two.feature" with:
    """
    Feature: Testfeature
    """

    When I run `geordi cucumber features/sub`
    Then the output should contain "> Only: features/sub/two.feature, features/sub/one.feature"
      And the output should contain "> Using parallel_tests"


  Scenario: Using the @solo tag

    The cucumber command runs all features without the @solo tag. If any of the
    .feature files contains '@solo', it boots Cucumber a second time and runs
    only the features tagged with @solo.

    Given a file named "features/no_solo.feature" with:
    """
    Feature: Test without solo tag
      Scenario: This scenario can run in parallel
    """
    And a file named "features/solo.feature" with:
    """
    Feature: Solo test
      @solo
      Scenario: This scenario must NOT run in parallel
    """

    When I run `geordi cucumber --verbose`
    Then the output should contain "# Running features"
      And the output should match /^> .*cucumber .*--tags ~@solo/
      And the output should contain "# Running @solo features"
      And the output should match /^> .*cucumber .*--tags @solo/


  Scenario: When there are no scenarios tagged @solo, the extra run is skipped
    Given a file named "features/no_solo.feature" with:
    """
    Feature: Test without solo tag
      Scenario: This scenario can run in parallel
    """

    When I run `geordi cucumber --verbose`
    Then the output should contain "# Running features"
      And the output should match /^> .*cucumber .*--tags ~@solo/
    But the output should not contain "# Running @solo features"
      And the output should not match /^> .*cucumber .*--tags @solo/


  Scenario: Specifying a firefox version to use
    Given a file named "features/sub/one.feature" with:
    """
    Feature: Testfeature
    """
    And a file named ".firefox-version" with:
    """
    24.0
    """

    When I run `geordi cucumber --verbose`
    Then the output should match /^> PATH=.*24.0:\$PATH.* cucumber/
