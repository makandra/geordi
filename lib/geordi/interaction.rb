# Use the methods in this file to communicate with the user
#
module Geordi
  module Interaction

    module_function

    # Start your command by `announce`-ing what you're about to do
    def announce(text)
      message = "\n# #{text}"
      puts "\e[4;34m#{message}\e[0m" # blue underline
    end

    # Any meta information, i.e. hints, comments, infos or explanations should
    # be printed with `note`.
    # Please do not use it for command output (data, file contents, lists etc).
    def note(text)
      puts '> ' + text
    end

    # Like `note`, but yellow. Use to warn the user.
    def warn(text)
      message = "> #{text}"
      puts "\e[33m#{message}\e[0m" # yellow
    end

    # Like `note`, but pink. Use to print (bash) commands.
    # Also see Util.run!
    def note_cmd(text)
      message = "> #{text}"
      puts "\e[35m#{message}\e[0m" # pink
    end

    # Exit execution with status code 1 and give a short note what happened,
    # e.g. "Failed" or "Cancelled"
    def fail(text)
      message = "\nx #{text}"
      puts "\e[31m#{message}\e[0m" # red
      exit(1)
    end

    # When you're done, inform the user with a `success` and a short message. It
    # should be a sentence (i.e. ending with [.!?]).
    def success(text)
      message = "\n> #{text}"
      puts "\e[32m#{message}\e[0m" # green
    end

    # Returns the user's input.
    # If agreement_regex is given, returns whether the input matches the regex.
    def prompt(text, default = nil, agreement_regex = nil)
      message = "#{text} "
      message << "[#{default}] " if default

      print "\e[36m#{message}\e[0m" # cyan
      input = $stdin.gets.strip
      input = default if input.empty? && default

      agreement_regex ? !!(input =~ agreement_regex) : input
    end

  end
end
