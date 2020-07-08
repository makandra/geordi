require 'rubygems'
require 'tempfile'

# This require-style is to prevent Ruby from loading files of a different
# version of Geordi.
require File.expand_path('interaction', __dir__)
require File.expand_path('firefox_for_selenium', __dir__)
require File.expand_path('settings', __dir__)

module Geordi
  class Cucumber

    VNC_DISPLAY = ':17'.freeze
    VNC_SERVER_COMMAND = "vncserver #{VNC_DISPLAY} -localhost -nolisten tcp -SecurityTypes None -geometry 1280x1024".freeze
    VNC_VIEWER_COMMAND = "vncviewer #{VNC_DISPLAY}".freeze
    VNC_ENV_VARIABLES = %w[DISPLAY BROWSER LAUNCHY_BROWSER].freeze

    def run(files, cucumber_options, options = {})
      self.argv = files + cucumber_options.map { |option| option.split('=') }.flatten
      self.settings = Geordi::Settings.new

      consolidate_rerun_txt_files
      show_features_to_run
      setup_vnc if settings.use_vnc?

      command = use_parallel_tests?(options) ? parallel_execution_command : serial_execution_command
      Interaction.note_cmd(command) if options[:verbose]

      puts # Make newline
      system command # Util.system! would reset the Firefox PATH
    end

    def launch_vnc_viewer
      fork do
        error = capture_stderr do
          system(VNC_VIEWER_COMMAND)
        end
        unless $?.success?
          if $?.exitstatus == 127
            Interaction.fail 'VNC viewer not found. Install it with `geordi vnc --setup`.'
          else
            Interaction.note 'VNC viewer could not be opened:'
            puts error
            puts
          end
        end
      end
    end

    def restore_env
      VNC_ENV_VARIABLES.each do |variable|
        ENV[variable] = ENV["OUTER_#{variable}"]
      end
    end

    def setup_vnc
      if try_and_start_vnc
        VNC_ENV_VARIABLES.each do |variable|
          ENV["OUTER_#{variable}"] = ENV[variable] if ENV[variable]
        end
        ENV['BROWSER'] = ENV['LAUNCHY_BROWSER'] = File.expand_path('../../bin/launchy_browser', __dir__)
        ENV['DISPLAY'] = VNC_DISPLAY

        Interaction.note 'Run `geordi vnc` to view the Selenium test browsers'
      end
    end

    private

    attr_accessor :argv, :settings

    def serial_execution_command
      format_args = []
      unless argv.include?('--format') || argv.include?('-f')
        format_args = spinner_available? ? ['--format', 'CucumberSpinner::CuriousProgressBarFormatter'] : ['--format', 'progress']
      end
      [use_firefox_for_selenium, 'b', 'cucumber', format_args, escape_shell_args(argv)].flatten.compact.join(' ')
    end

    def parallel_execution_command
      Interaction.note 'Using parallel_tests'
      self.argv = argv - command_line_features

      type_arg = Util.gem_version('parallel_tests') > Gem::Version.new('0.7.0') ? 'cucumber' : 'features'
      features = features_to_run
      features = find_all_features_recursively('features') if features.empty?

      [
        use_firefox_for_selenium,
        'b parallel_test -t ' + type_arg,
        %(-o '#{command_line_options.join(' ')} --tags "#{not_tag('@solo')}"'),
        "-- #{features.join(' ')}",
      ].compact.join(' ')
    end

    def not_tag(name)
      if Util.gem_major_version('cucumber') < 3
        "~#{name}"
      else
        "not #{name}"
      end
    end

    def use_firefox_for_selenium
      path = Geordi::FirefoxForSelenium.path_from_config
      if path
        "PATH=#{path}:$PATH"
      end
    end

    def escape_shell_args(*args)
      args.flatten.collect do |arg|
        arg.gsub(/([\\ "])/) { |_match| "\\#{Regexp.last_match(1)}" }
      end
    end

    def show_features_to_run
      if command_line_options.include? '@solo'
        Interaction.note 'All features tagged with @solo'
      elsif command_line_options.include? 'rerun'
        Interaction.note 'Rerunning failed scenarios'
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

    def try_and_start_vnc
      # check if vnc is already running
      # return true if vnc_server_running?
      error = capture_stderr do
        system(VNC_SERVER_COMMAND)
      end
      case $?.exitstatus
      when 0,
        98 # was already running after all
        true
      when 127 # not installed
        Interaction.warn 'Could not launch VNC server. Install it with `geordi vnc --setup`.'
        false
      else
        Interaction.warn 'Starting VNC failed:'
        puts error
        puts
        false
      end
    end

    def capture_stderr
      old_stderr = $stderr.dup
      io = Tempfile.new('cuc')
      $stderr.reopen(io)
      yield
      io.rewind
      io.read
    ensure
      io.close
      io.unlink
      $stderr.reopen(old_stderr)
    end

  end
end
