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
      And the output should contain "Features green."
    But the output should not contain "> Using parallel_tests"


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
      And the output should contain "Features failed."


  # https://github.com/makandra/geordi/issues/27
  Scenario: A rerun should only consider the specified file
    Note that we need a cucumber.yml to write the rerun.txt and read the rerun.txt for the reruns.

    Given a file named "features/step_definitions/test_steps.rb" with:
    """
    Given /^this step fails$/ do
      raise
    end

    Given /^I use puts with text "(.*)"$/ do |ann|
      puts(ann)
    end
    """
      And a file named "features/failing.feature" with:
      """
      Feature: Failing feature
        Scenario: Passing scenario
          And I use puts with text "passing feature"

        Scenario: Failing scenario
          And I use puts with text "failing feature"
          And this step fails
      """
      And an empty file named "tmp/rerun.txt"
      And a file named "cucumber.yml" with:
      """
      <%
      rerun_log = 'tmp/rerun.txt'
      rerun_failures = File.file?(rerun_log) ? File.read(rerun_log).gsub("\n", ' ') : ''
      log_failures = "--format=rerun --out=#{rerun_log}"
      %>
      default: features <%= log_failures %>
      rerun: <%= rerun_failures %> <%= log_failures %>
      """

    When I run `geordi cucumber --rerun=1 features/failing.feature`
    # The command output includes both the first and the second run ("rerun").
    # Checking output of the first run ...
    Then the output should contain:
    """
    passing feature
    .
    failing feature
    .F
    """
    # ... and of the rerun. Only seeing "failing feature" here => passing
    # feature was not rerun.
    Then the output should contain:
    """
    Using the rerun profile...

    failing feature
    .F
    """


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
    # File order is non-deterministic
    Then the output should match /> Only:.* features.sub.one\.feature/
      And the output should match /> Only:.* features.sub.two\.feature/
      And the output should contain "> Using parallel_tests"


  Scenario: Running all cucumber features matching a given string
    Given a file named "features/given.feature" with "Feature: given"
    And a file named "features/other.feature" with "Feature: other"

    When I run `geordi cucumber --containing given`
    Then the output should contain "Only: features/given.feature"
    But the output should not contain "other.feature"


  Scenario: Passing a format argument will skip the default format for a single run
    Given a file named "features/single.feature" with:
    """
    Feature: Running a single feature
      Scenario: A single scenario
    """

    When I run `geordi cucumber features/single.feature --format=pretty --verbose`
    Then the output should contain "bundle exec cucumber features/single.feature --format pretty"


  Scenario: A cucumber binstub is used if present
    Given a file named "bin/cucumber" with "binstub"
    Given a file named "features/single.feature" with "Feature: Test"

    # Passing a line number activates serial test execution
    When I run `geordi cucumber --verbose single.feature:1`
    Then the output should contain "> bin/cucumber"


  Scenario: Invalid config keys are not reported twice in the same geordi command
    Given a file named "tmp/global_settings.yml" with "use_vnc: false"
    Given a file named "features/cucumber.feature" with:
    """
    Feature: Running a single feature
      Scenario: A scenario
    """

    When I run `geordi cucumber features/cucumber.feature`
    Then the output should contain '> Unknown settings in ./tmp/global_settings.yml: use_vnc' 1 time
      And the output should contain '> Supported settings in ./tmp/global_settings.yml are: ' 1 time


  Scenario: Invalid config keys are reported twice in two consecutive executions of geordi
    Given a file named "tmp/global_settings.yml" with "use_vnc: false"
    Given a file named "features/cucumber.feature" with:
    """
    Feature: Running a single feature
      Scenario: A scenario
    """

    When I run `geordi cucumber features/cucumber.feature`
    Then the output should contain '> Unknown settings in ./tmp/global_settings.yml: use_vnc' 1 time
      And the output should contain '> Supported settings in ./tmp/global_settings.yml are: ' 1 time

    When I ignore previous output
      And I run `geordi cucumber features/cucumber.feature`
    Then the output should contain '> Unknown settings in ./tmp/global_settings.yml: use_vnc' 1 time
      And the output should contain '> Supported settings in ./tmp/global_settings.yml are: ' 1 time

  Scenario: When running cucumber tests with a .firefox-version in the project root, a warning is issued
    Given a file named ".firefox-version" with "1.2.3"
    Given a file named "features/cucumber.feature" with:
    """
    Feature: Running multiple features
      Scenario: A scenario
    """

    When I run `geordi cucumber features/cucumber.feature`
    Then the output should contain '> Unsupported config file ".firefox-version". Please remove it.' 1 time
