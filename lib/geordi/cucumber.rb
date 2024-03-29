require 'rubygems'
require 'tempfile'

# This require-style is to prevent Ruby from loading files of a different
# version of Geordi.
require File.expand_path('interaction', __dir__)
require File.expand_path('settings', __dir__)

module Geordi
  class Cucumber
    def run(arguments, options = {})
      split_arguments = arguments.map { |arg| arg.split('=') }.flatten

      self.argv = split_arguments.map do |arg|
        # Ensure arguments containing white space are kept together
        arg.match?(/\S\s\S/) ? %('#{arg}') : arg
      end

      self.settings = Geordi::Settings.new

      consolidate_rerun_txt_files
      show_features_to_run

      command = use_parallel_tests?(options) ? parallel_execution_command : serial_execution_command
      Interaction.note_cmd(command) if options[:verbose]

      puts # Make newline
      system command
    end

    private

    attr_accessor :argv, :settings

    def serial_execution_command
      format_args = []
      unless argv.include?('--format') || argv.include?('-f')
        format_args = spinner_available? ? ['--format', 'CucumberSpinner::CuriousProgressBarFormatter'] : ['--format', 'progress']
      end
      if argv.include?('rerun')
        drop_command_line_features!
      end
      [ Util.binstub_or_fallback('cucumber'), format_args, escape_shell_args(argv)].flatten.compact.join(' ')
    end

    def parallel_execution_command
      Interaction.note 'Using parallel_tests'
      drop_command_line_features!

      type_arg = Util.gem_version('parallel_tests') > Gem::Version.new('0.7.0') ? 'cucumber' : 'features'
      features = features_to_run
      features = find_all_features_recursively('features') if features.empty?
      [
        'bundle exec parallel_test -t ' + type_arg,
        %(-o "#{command_line_options.join(' ')}"),
        "-- #{features.join(' ')}",
      ].compact.join(' ')
    end

    def drop_command_line_features!
      self.argv = argv - command_line_features
    end

    def escape_shell_args(*args)
      args.flatten.collect do |arg|
        arg.gsub(/([\\ "])/) { |_match| "\\#{Regexp.last_match(1)}" }
      end
    end

    def show_features_to_run
      if command_line_options.include?('rerun')
        Interaction.note 'Rerunning failed scenarios'
      elsif command_line_tag_options.any?
        Interaction.note "Only features matching tag option #{command_line_tag_options.join(',')}"
      elsif features_to_run.empty?
        Interaction.note 'All features in features/'
      else
        notification = 'Only: ' + features_to_run.join(', ')
        notification << ' (from rerun.txt)' if (features_to_run == rerun_txt_features) && (features_to_run != command_line_features)
        Interaction.note notification
      end
    end

    def features_to_run
      @features_to_run ||= begin
        features = find_all_features_recursively(command_line_features)
        features = rerun_txt_features if features.empty?
        features
      end
    end

    def rerun_txt_features
      @rerun_txt_features ||= begin
        if File.exist?('rerun.txt')
          IO.read('rerun.txt').to_s.strip.split(/\s+/)
        else
          []
        end
      end
    end

    def command_line_features
      @command_line_features ||= argv - command_line_options
    end

    def command_line_options
      @command_line_options ||= [].tap do |args|
        # Sorry for this mess. Option parsing doesn't get much prettier.
        argv.each_cons(2) do |a, b|
          break if a == '--' # This is the common no-options-beyond marker

          case a
          when '-f', '--format', '-p', '--profile', '-t', '--tags'
            args << a << b # b is the value for the option
          else
            args << a if a.start_with? '-'
          end
        end

        # Since we're using each_cons(2), the loop above will never process the
        # last arg. Do it manually here.
        last_arg = argv.last
        args << last_arg if (last_arg && last_arg.start_with?('-'))
      end
    end

    def command_line_tag_options
      [].tap do |tag_options|
        command_line_options.each_cons(2) do |option, tags|
          tag_options << tags if option =~ /--tags|-t/
        end
      end
    end

    def consolidate_rerun_txt_files
      parallel_rerun_files = Dir.glob('parallel_rerun*.txt')
      unless parallel_rerun_files.empty?
        Interaction.note 'Consolidating parallel_rerun.txt files ...'

        rerun_content = []
        parallel_rerun_files.each do |filename|
          rerun_content << File.read(filename).strip
          File.unlink(filename)
        end

        File.open('rerun.txt', 'w') do |f|
          f.puts(rerun_content.join(' '))
        end
      end
    end

    def find_all_features_recursively(files_or_dirs)
      Array(files_or_dirs).map do |file_or_dir|
        if File.directory?(file_or_dir)
          file_or_dir = Dir.glob(File.join(file_or_dir, '**', '*.feature'))
        end
        file_or_dir
      end.flatten.uniq.compact
    end

    def spinner_available?
      @spinner_available ||= File.exist?('Gemfile') && File.open('Gemfile').read.scan(/cucumber_spinner/).any?
    end

    def use_parallel_tests?(options)
      options.fetch(:parallel, true) &&
        features_to_run.size != 1 &&
        Util.gem_available?('parallel_tests') &&
        features_to_run.none? { |f| f.include? ':' }
    end

  end
end
