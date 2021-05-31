Feature: The tests command

  Scenario: Run all tests
    Given an empty file named "test/test_helper.rb"
      And an empty file named "spec/spec_helper.rb"
      And an empty file named "features/some.feature"
    When I run `geordi tests`
    Then the output should contain "# Running Test::Unit"
      And the output should contain "# Running specs"
      And the output should contain "# Running features"

  Scenario: Run only certain specs
    Given an empty file named "spec/spec_helper.rb"
      And an empty file named "spec/some_spec.rb"

    When I run `geordi tests spec/some_spec.rb`
    Then the output should contain "# Running specs"
      And the output should contain "Only: spec/some_spec.rb"

  Scenario: Run only certain features
    Given an empty file named "features/some.feature"

    When I run `geordi tests features/some.feature`
    Then the output should contain "# Running features"
      And the output should contain "> Only: features/some.feature"

  Scenario: Run only tests in a directory
    Given an empty file named "spec/spec_helper.rb"
      And an empty file named "features/some.feature"

    When I run `geordi tests spec`
    Then the output should contain "# Running specs"
      And the output should contain "Only: spec"

    When I run `geordi tests features`
    Then the output from "geordi tests features" should contain "# Running features"
      And the output from "geordi tests features" should contain "> Only: features"

  Scenario: Geordi's options are processed
    Given an empty file named "features/some.feature"

    When I run `geordi tests features/some.feature -v`
    Then the output should contain "> bundle exec cucumber"

    When I run `geordi tests features/some.feature`
    Then the output from "geordi tests features/some.feature" should not contain "> bundle exec cucumber"

  Scenario: Unknown options are passed through
    Given an empty file named "spec/spec_helper.rb"

    When I run `geordi tests spec/ --some-option`
    Then the output should contain "Util.run! bundle exec rspec spec/ --some-option"
