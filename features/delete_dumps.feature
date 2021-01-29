Feature: Deleting *.dump files

  Scenario: Finds dumps in default location when run without arguments

    Default locations are ~/dumps and the current directory.

    When I run `geordi delete-dumps`
    Then the output should contain "Retrieving dump files"
      And the output should match %r<Looking in /home/.+?/dumps, /home/.+?/geordi/tmp/aruba>


  Scenario: Delete dumps in given directory
    Given a file named "dir/test.dump" with "Test dump file"

    When I run `geordi delete-dumps dir` interactively
      # Confirm deletion prompt
      And I type "y"
    Then the output should contain "/dir/test.dump"
      And the output should contain "Delete these files?"
      And the output should contain "Done."
      And the file named "dir/test.dump" should not exist anymore
