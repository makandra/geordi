require 'pathname'
require 'tempfile'
require File.expand_path('interaction', __dir__)

module Geordi
  module FirefoxForSelenium
    extend Geordi::Interaction

    FIREFOX_FOR_SELENIUM_BASE_PATH = Pathname.new('~/bin/firefoxes').expand_path
    FIREFOX_FOR_SELENIUM_PROFILE_NAME = 'firefox-for-selenium'.freeze
    FIREFOX_VERSION_FILE = Pathname.new('.firefox-version')

    def self.install(version)
      Installer.new(version).run
    end

    def self.path_from_config
      version = FIREFOX_VERSION_FILE.exist? && File.read(FIREFOX_VERSION_FILE).strip

      if version && (version != 'system')
        unless FirefoxForSelenium.binary(version).exist?
          warn "Firefox #{version} not found"

          note strip_heredoc(<<-INSTRUCTIONS)
          Install it with
            geordi firefox --setup #{version}
          INSTRUCTIONS

          prompt('Run tests anyway?', 'n', /y|yes/) || raise('Cancelled.')
        end

        path(version)
      end
    end

    def self.path(version)
      FIREFOX_FOR_SELENIUM_BASE_PATH.join(version)
    end

    def self.binary(version, name = 'firefox')
      path(version).join(name)
    end

    def self.setup_firefox
      path = path_from_config

      if path
        ENV['PATH'] = "#{path}:#{ENV['PATH']}"
        note 'Firefox for Selenium set up'
      end
    end


    class Installer
      include Geordi::Interaction

      def initialize(version)
        @version = version
      end

      def run
        say_hello
        check_if_run_before
        download_firefox
        create_separate_profile # do this before the patching because the patched binary calls firefox with a profile that does not yet exist
        patch_old_firefox
        configure_old_firefox
        kkthxbb
      end


      private

      def execute_command(cmd)
        system(cmd) || raise("Error while executing command: #{cmd}")
      end

      def run_firefox_for_selenium(args = '')
        execute_command("PATH=#{path}:$PATH firefox #{args}")
      end

      def path
        FirefoxForSelenium.path(@version)
      end

      def download_url
        "https://ftp.mozilla.org/pub/firefox/releases/#{@version}/"
      end

      def binary
        FirefoxForSelenium.binary(@version)
      end

      def original_binary
        FirefoxForSelenium.binary(@version, 'firefox-original')
      end

      def say_hello
        execute_command('clear')

        puts strip_heredoc(<<-HELLO)
        Whenever Firefox updates, Selenium breaks. This is annoying. This
        script will help you create an unchanging version of Firefox for your
        Selenium tests.

        In particular, this new copy of Firefox will have the following
        properties:

        - It won't update itself with a newer version
        - It can co-exist with your regular Firefox installation (which you can
          update at will)
        - It will use a profile separate from the one you use for regular
          Firefox browsing
        - It will not try to re-use existing Firefox windows
        - It will automatically be used for your Selenium scenarios if you run
          your Cucumber using the cuc binary from the geordi gem.
        - It will live in #{path}
        HELLO

        prompt "Press ENTER when you're ready to begin."
      end

      def check_if_run_before
        if original_binary.exist?
          note 'This version seems to be already installed.'
          prompt 'Press ENTER to continue anyway or press CTRL+C to abort.'
        end
      end

      def download_firefox
        path.mkpath

        puts strip_heredoc(<<-INSTRUCTION)
        Please download an old version of Firefox from: #{download_url}
        Unpack it with: tar xjf firefox-#{@version}.tar.bz2 -C #{path} --strip-components=1
        Now #{path.join('firefox')} should be the firefox binary, not a directory.
        INSTRUCTION
        prompt 'Continue?'

        File.file?(binary) || raise("Could not find #{binary}")
      end

      def create_separate_profile
        note "Creating a separate profile named '#{FIREFOX_FOR_SELENIUM_PROFILE_NAME}' so your own profile will be safe..."
        # don't use the patched firefox binary for this, we don't want to give
        # a -p option here
        execute_command("PATH=#{path}:$PATH firefox -no-remote -CreateProfile #{FIREFOX_FOR_SELENIUM_PROFILE_NAME}")
        puts
      end

      def patch_old_firefox
        note "Patching #{binary} so it uses the new profile and never re-uses windows from other Firefoxes..."
        execute_command("mv #{binary} #{original_binary}")
        execute_command("mv #{binary}-bin #{original_binary}-bin")
        patched_binary = Tempfile.new('firefox')
        patched_binary.write strip_heredoc(<<-PATCH)
          #!/usr/bin/env ruby
          exec('#{original_binary}', '-no-remote', '-P', '#{FIREFOX_FOR_SELENIUM_PROFILE_NAME}', *ARGV)
        PATCH
        patched_binary.close
        execute_command("mv #{patched_binary.path} #{binary}")
        execute_command("chmod +x #{binary}")
        puts
      end

      def configure_old_firefox
        puts strip_heredoc(<<-INSTRUCTION)
        You will now have to do some manual configuration.

        This script will open the patched copy of Firefox when you press ENTER.
        Please perform the following steps manually:

        - IMPORTANT: Quickly disable all automatic updates under Edit /
          Preferences / Advanced / Update
        - Disable the default browser check when Firefox launches
        - Check that the version number is correct (#{@version})
        - You should not see your bookmarks, add-ons, plugins from your regular
          Firefox profile
        INSTRUCTION

        prompt 'Will open the patched copy of Firefox now'
        run_firefox_for_selenium
      end

      def kkthxbb
        success "Congratulations, you're done!"

        puts
        puts strip_heredoc(<<-INSTRUCTION)
        Your patched copy of Firefox will be used when you run Cucumber using
        the cucumber script that comes with the geordi gem. If you cannot use
        `geordi cucumber`, but still need the test browser set up, you can use:

            geordi firefox <any command>

        Enjoy!
        INSTRUCTION
      end

    end
  end
end
