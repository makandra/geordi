module Geordi
  module Interaction

    def announce(text)
      message = "\n# #{text}"
      puts "\e[4;34m#{message}\e[0m" # blue underline
    end

    def note(text)
      puts '> ' + text
    end

    def warn(text)
      message = "> #{text}"
      puts "\e[33m#{message}\e[0m" # yellow
    end

    def note_cmd(text)
      message = "> #{text}"
      puts "\e[35m#{message}\e[0m" # pink
    end

    def fail(text)
      message = "\nx #{text}"
      puts "\e[31m#{message}\e[0m" # red
      exit(1)
    end

    def success(text)
      message = "\n> #{text}"
      puts "\e[32m#{message}\e[0m" # green
    end

    def strip_heredoc(string)
      leading_whitespace = (string.match(/\A( +)[^ ]+/) || [])[1]
      string.gsub! /^#{leading_whitespace}/, '' if leading_whitespace
      string
    end

    # Returns the user's input.
    # If agreement_regex is given, returns whether the input matches the regex.
    def prompt(text, default = nil, agreement_regex = nil)
      message = "#{text} "
      message << "[#{default}] " if default

      puts
      print "\e[36m#{message}\e[0m" # cyan
      input = $stdin.gets.strip
      input = default if input.empty? && default

      agreement_regex ? !!(input =~ agreement_regex) : input
    end

  end
end
