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
      And the output should contain "Rerunning failed scenarios"
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
    specified .feature files contains '@solo', it boots Cucumber a second time
    and runs only those of the features tagged with @solo.

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

    When I run `geordi cucumber --verbose features`
    Then the output should contain "# Running features"
      And the output should match /^> .*cucumber .*--tags \"~@solo\"/
      And the output should contain "# Running @solo features"
      And the output should match /^> .*cucumber .*--tags @solo/


  Scenario: When there are no scenarios tagged @solo, the extra run is skipped
    Given a file named "features/no_solo/one.feature" with:
    """
    Feature: Test without solo tag
      Scenario: This scenario can run in parallel
    """
    And a file named "features/no_solo/two.feature" with:
    """
    Feature: A second test to provoke a parallel run
      Scenario: Something
    """
    And a file named "features/solo.feature" with:
    """
    Feature: Solo test
      @solo
      Scenario: This scenario is not even run during this test
    """

    When I run `geordi cucumber features/no_solo --verbose`
    Then the output should contain "# Running features"
      And the output should match /^> .*features .*--tags \"~@solo\"/
    But the output should not contain "# Running @solo features"


  Scenario: When called with line numbers, the @solo extra run is skipped

    Note that with line numbers in the passed file names, features are run
    serially.

    Given a file named "features/example.feature" with:
    """
    Feature: Test without solo tag
      Scenario: Example scenario
      Scenario: Other scenario
    """

    When I run `geordi cucumber --verbose features/example.feature:2`
    Then the output should contain "# Running features"
    But the output should not contain "# Running @solo features"
      # Regression test, with line numbers grep would fail with:
      #   grep: features/example.feature:2: No such file or directory
      And the output should not contain "No such file or directory"


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
    Then the output should match /^> PATH=.*24.0:\$PATH.* features/


  Scenario: Running all cucumber features matching a given string
    Given a file named "features/given.feature" with "Feature: given"
    And a file named "features/other.feature" with "Feature: other"

    When I run `geordi cucumber --containing given`
    Then the output should contain "Only: features/given.feature"
    But the output should not contain "other.feature"
