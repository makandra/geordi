require 'rubygems'
require 'geordi/setup_firefox_for_selenium'

module Geordi
  class Cucumber

    def run
      4.times { puts }
      puts "Running Cucumber tests..."
      puts "========================="

      consolidate_rerun_txt_files
      show_rerun_txt_file_content

      command = use_parallel_tests? ? parallel_execution_command : serial_execution_command
      exec command
    end

    def serial_execution_command
      format_args = spinner_available ? ['--format', 'CucumberSpinner::CuriousProgressBarFormatter'] : ['--format', 'progress']
      [use_firefox_for_selenium, "b", "cucumber", format_args, escape_shell_args(ARGV)].flatten.compact.join(" ")
    end


    def parallel_execution_command
      puts "Using parallel_tests ...\n\n"
      parallel_tests_args = '-t features'
      cucumber_args = ARGV.empty? ? '' : "-o '#{escape_shell_args(ARGV).join(" ")}'"
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


    def rerun_txt_exists_and_has_content?
      File.exists?("rerun.txt") && !IO.read("rerun.txt").to_s.strip.empty?
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


    def show_rerun_txt_file_content
      return unless rerun_txt_exists_and_has_content?

      2.times { puts }
      puts "content of rerun.txt:"
      puts "-------------------------"
      puts File.read('rerun.txt')
      puts "-------------------------"
      2.times { puts }
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
      parallel_tests_available? && !rerun_txt_exists_and_has_content?
    end

  end
end
