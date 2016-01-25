Feature: The cucumber command

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
    Then the output should contain "Running features"
      And the output should match /^> .*b cucumber .*--tags ~@solo/
    But the output should not contain "Running @solo features"
      And the output should not match /^> .*b cucumber .*--tags @solo/
