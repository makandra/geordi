Feature: The `launchy_browser` binary

  Scenario: Opening a URL
    # Add path to Ruby's load path
    Given I set the environment variable "RUBYLIB" to "test_bin"
      And a file named "test_bin/launchy.rb" with:
      """
      class Launchy
        def self.open(url)
          puts "[fake] Launchy.open('#{ url }')"
        end
      end
      """

    When I run `launchy_browser http://www.example.com`
    Then the output should contain "[fake] Launchy.open('http://www.example.com')"
