require 'pathname'

module Geordi
  module FirefoxForSelenium

    FIREFOX_FOR_SELENIUM_BASE_PATH = Pathname.new('~/bin/firefoxes').expand_path
    FIREFOX_FOR_SELENIUM_PROFILE_NAME = 'firefox-for-selenium'
    DEFAULT_FIREFOX_VERSION = "5.0.1"
    VERSION_SPECIFICATION_FILE = Pathname.new(".firefox-version")

    def self.install
      Installer.new.run
    end

    def self.path_from_config
      PathFromConfig.new.run
    end

    def self.path(version)
      FIREFOX_FOR_SELENIUM_BASE_PATH.join(version)
    end

    def self.binary(version, name = "firefox")
      path(version).join(name)
    end

    def self.setup_firefox
      path = path_from_config
      if path
        ENV['PATH'] = "#{path}:#{ENV['PATH']}"
      end
    end


    class PathFromConfig

      def run
        unless system_firefox
          get_version
          validate_install
          path
        end
      end

      private

      def path
        FirefoxForSelenium.path(@version)
      end

      def system_firefox
        version_from_cuc_file == "system"
      end

      def get_version
        @version = version_from_cuc_file || default_version
      end

      def default_version
        puts "No firefox version given, defaulting to #{DEFAULT_FIREFOX_VERSION}."
        puts "Specify a version by putting it in a file named \"#{VERSION_SPECIFICATION_FILE}\"."
        puts
        DEFAULT_FIREFOX_VERSION
      end

      def validate_install
        unless FirefoxForSelenium.binary(@version).exist?
          puts "Firefox #{@version} not found."
          puts "Install it with"
          puts "  setup-firefox-for-selenium #{@version}"
          puts
          puts "If you want to use your system firefox and not see this message, add"
          puts "a \".firefox-version\" file with the content \"system\"."
          puts
          puts "Press ENTER to continue or press CTRL+C to abort."
          $stdin.gets
        end
      end

      def version_from_cuc_file
        File.read(VERSION_SPECIFICATION_FILE).strip if VERSION_SPECIFICATION_FILE.exist?
      end

    end


    class Installer

      def run
        parse_version
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
        system(cmd) or raise "Error while executing command: #{cmd}"
      end

      def run_firefox_for_selenium(args = '')
        execute_command("PATH=#{path}:$PATH firefox #{args}")
      end

      def die(message)
        puts message
        puts
        exit(1)
      end

      def path
        FirefoxForSelenium.path(@version)
      end

      def download_url
        "ftp://ftp.mozilla.org/pub/firefox/releases/#{@version}/"
      end

      def binary
        FirefoxForSelenium.binary(@version)
      end

      def original_binary
        FirefoxForSelenium.binary(@version, "firefox-original")
      end

      def parse_version
        @version = ARGV.pop
        @version or die("Usage: setup_firefox_for_selenium VERSION")
      end

      def say_hello
        execute_command('clear')
        puts "Whenever Firefox updates, Selenium breaks. This is annoying."
        puts "This script will help you create an unchanging version of Firefox for your Selenium tests."
        puts
        puts "In particular, this new copy of Firefox will have the following properties:"
        puts
        puts "- It won't update itself with a newer version"
        puts "- It can co-exist with your regular Firefox installation (which you can update at will)"
        puts "- It will use a profile separate from the one you use for regular Firefox browsing"
        puts "- It will not try to re-use existing Firefox windows"
        puts "- It will automatically be used for your Selenium scenarios if you run your Cucumber using the cuc binary from the geordi gem."
        puts "- It will live in #{path}"
        puts
        puts "Press ENTER when you're ready to begin."
        gets
      end

      def check_if_run_before
        if original_binary.exist?
          puts "This version seems to be already installed."
          puts
          puts "Press ENTER to continue anyway or press CTRL+C to abort."
          gets
        end
      end

      def download_firefox
        path.mkpath
        puts "Please download an old version of Firefox from #{download_url} and unpack it to #{path}."
        puts "Don't create an extra #{path.join("firefox")} directory."
        puts
        puts "Press ENTER when you're done."
        gets
        File.file?(binary) or raise "Could not find #{binary}"
      end

      def create_separate_profile
        puts "Creating a separate profile named '#{FIREFOX_FOR_SELENIUM_PROFILE_NAME}' so your own profile will be safe..."
        # don't use the patched firefox binary for this, we don't want to give a -p parameter here
        execute_command("PATH=#{path}:$PATH firefox -no-remote -CreateProfile #{FIREFOX_FOR_SELENIUM_PROFILE_NAME}")
        puts
      end

      def patch_old_firefox
        puts "Patching #{binary} so it uses the new profile and never re-uses windows from other Firefoxes..."
        execute_command("mv #{binary} #{original_binary}")
        execute_command("mv #{binary}-bin #{original_binary}-bin")
        patched_binary = Tempfile.new('firefox')
        patched_binary.write <<eos
#!/usr/bin/env ruby
exec('#{original_binary}', '-no-remote', '-P', '#{FIREFOX_FOR_SELENIUM_PROFILE_NAME}', *ARGV)
eos
        patched_binary.close
        execute_command("mv #{patched_binary.path} #{binary}")
        execute_command("chmod +x #{binary}")
        puts
      end

      def configure_old_firefox
        puts "This script will now open the patched copy of Firefox."
        puts
        puts "Please perform the following steps manually:"
        puts
        puts "- Disable the default browser check when Firefox launches"
        puts "- Check that the version number is correct (#{@version})"
        puts "- Disable all automatic updates under Edit / Preferences / Advanced / Update (do this quickly or Firefox will already have updated)"
        puts "- You should not see your bookmarks, addons, plugins from your regular Firefox profile"
        puts
        puts "Press ENTER when you're ready to open Firefox and perform these steps."
        gets
        run_firefox_for_selenium
      end

      def kkthxbb
        puts "Congratulations, you're done!"
        puts
        puts "Your patched copy of Firefox will be used when you run Cucumber using the cuc binary that comes with the geordi gem."
        puts "If you prefer to run Cucumber on your own, you must call it like this:"
        puts
        puts "    PATH=#{path}:$PATH cucumber"
        puts
        puts "Enjoy!"
        puts
      end

    end
  end
end

