require 'rubygems'
require 'geordi/setup_firefox_for_selenium'
require 'ruby-debug'

module Geordi
  class Cucumber

    def run
      4.times { puts }
      puts "Running Cucumber tests..."
      puts "========================="

      consolidate_rerun_txt_files
      show_features_to_run

      command = use_parallel_tests? ? parallel_execution_command : serial_execution_command

      if argv.include? "-v"
        puts command
        2.times { puts }
      end

      2.times { puts }
      exec command
    end


    attr_writer :argv
    def argv
      @argv ||= ARGV
    end

    def serial_execution_command
      format_args = spinner_available? ? ['--format', 'CucumberSpinner::CuriousProgressBarFormatter'] : ['--format', 'progress']
      [use_firefox_for_selenium, "b", "cucumber", format_args, escape_shell_args(argv)].flatten.compact.join(" ")
    end


    def parallel_execution_command
      puts "Using parallel_tests ...\n\n"
      self.argv = argv - command_line_features
      require 'parallel_tests'
      type_arg = Gem::Version.new(::ParallelTests::VERSION) > Gem::Version.new('0.7.0') ? 'cucumber' : 'features'
      parallel_tests_args = "-t #{type_arg} #{command_line_features.join(' ')}"
      cucumber_args = argv.empty? ? '' : "-o '#{escape_shell_args(argv).join(" ")}'"
      [use_firefox_for_selenium, 'b', 'parallel_test', parallel_tests_args, cucumber_args].flatten.compact.join(" ")
    end


    def use_firefox_for_selenium
      "PATH=#{Geordi::SetupFirefoxForSelenium::FIREFOX_FOR_SELENIUM_PATH}:$PATH"
    end


    def escape_shell_args(*args)
      args.flatten.collect do |arg|
        arg.gsub(/([\\ "])/) { |match| "\\#{$1}" }
      end
    end

    def show_features_to_run
      unless features_to_run.empty?
        passed_by = (features_to_run == command_line_features) ? 'command line' : 'rerun.txt'
        2.times { puts }
        puts "features to run (passed by #{passed_by}):"
        puts "-----------------------------------------"
        puts features_to_run.join("\n")
        puts "-----------------------------------------"
      end
    end

    def features_to_run
      @features_to_run ||= begin
        features = command_line_features
        features = rerun_txt_features if features.empty?
        features
      end
    end

    def command_line_features
      @command_line_features ||= argv.select do |arg|
        arg =~ /.*\.feature/i
      end
    end

    def rerun_txt_features
      @rerun_txt_features ||= begin
        if File.exists?("rerun.txt")
          IO.read("rerun.txt").to_s.strip.split(/\s+/)
        else
          []
        end
      end
    end

    def consolidate_rerun_txt_files
      parallel_rerun_files = Dir.glob("parallel_rerun*.txt")
      unless parallel_rerun_files.empty?
        2.times { puts }
        puts "consolidating parallel_rerun.txt files ..."

        rerun_content = []
        parallel_rerun_files.each do |filename|
          rerun_content << File.read(filename).strip
          File.unlink(filename)
        end

        File.open("rerun.txt", "w") do |f|
          f.puts(rerun_content.join(" "))
        end
      end
    end

    def features_can_run_with_parallel_tests?(features)
      not features.any?{ |feature| feature.include? ":" }
    end


    # Check if cucumber_spinner is available
    def spinner_available?
      @spinner_available ||= File.exists?('Gemfile') && File.open('Gemfile').read.scan(/cucumber_spinner/).any?
    end


    # Check if parallel_tests is available
    def parallel_tests_available?
      @parallel_tests_available ||= File.exists?('Gemfile') && File.open('Gemfile').read.scan(/parallel_tests/).any?
    end


    def use_parallel_tests?
      parallel_tests_available? && features_can_run_with_parallel_tests?(features_to_run) && features_to_run.size > 1
    end

  end
end
