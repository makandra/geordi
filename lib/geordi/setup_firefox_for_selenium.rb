module Geordi
  class SetupFirefoxForSelenium

    FIREFOX_FOR_SELENIUM_PATH = '/opt/firefox-for-selenium'
    FIREFOX_FOR_SELENIUM_BINARY = "#{FIREFOX_FOR_SELENIUM_PATH}/firefox"
    ORIGINAL_FIREFOX_BINARY = "#{FIREFOX_FOR_SELENIUM_PATH}/firefox-original"
    FIREFOX_FOR_SELENIUM_PROFILE_NAME = 'firefox-for-selenium'

    class << self

      def execute_command(cmd)
        system(cmd) or raise "Error while executing command: #{cmd}"
      end

      def run_firefox_for_selenium(args = '')
        execute_command("PATH=#{FIREFOX_FOR_SELENIUM_PATH}:$PATH firefox #{args}")
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
        puts "- It will live in #{FIREFOX_FOR_SELENIUM_PATH}"
        puts
        puts "At some point, this script will ask you for your user password, because some operations need to be run as root."
        puts
        puts "Press ENTER when you're ready to begin."
        gets
      end

      def check_if_run_before
        if File.exists?(ORIGINAL_FIREFOX_BINARY)
          puts "It looks like you have run this script before. No good can come from running this script a second time on the same copy of Firefox."
          puts
          puts "Press ENTER to continue anyway or press CTRL+C to abort."
          gets
        end
      end

      def download_old_firefox
        puts "Please download an old version of Firefox from ftp://ftp.mozilla.org/pub/firefox/releases/5.0.1/ and unpack it to #{FIREFOX_FOR_SELENIUM_PATH}"
        puts
        puts "Press ENTER when you're done."
        gets
        File.file?(FIREFOX_FOR_SELENIUM_BINARY) or raise "Could not find #{FIREFOX_FOR_SELENIUM_BINARY}"
      end

      def create_separate_profile
        puts "Creating a separate profile named '#{FIREFOX_FOR_SELENIUM_PROFILE_NAME}' so your own profile will be safe..."
        # don't use the patched firefox binary for this, we don't want to give a -p parameter here
        execute_command("PATH=#{FIREFOX_FOR_SELENIUM_PATH}:$PATH firefox -no-remote -CreateProfile #{FIREFOX_FOR_SELENIUM_PROFILE_NAME}")
        puts
      end

      def patch_old_firefox
        puts "Patching #{FIREFOX_FOR_SELENIUM_BINARY} so it uses the new profile and never re-uses windows from other Firefoxes..."
        execute_command("sudo mv #{FIREFOX_FOR_SELENIUM_BINARY} #{ORIGINAL_FIREFOX_BINARY}")
        execute_command("sudo mv #{FIREFOX_FOR_SELENIUM_BINARY}-bin #{ORIGINAL_FIREFOX_BINARY}-bin")
        patched_binary = Tempfile.new('firefox')
        patched_binary.write <<eos
#!/usr/bin/env ruby
exec('#{ORIGINAL_FIREFOX_BINARY}', '-no-remote', '-P', '#{FIREFOX_FOR_SELENIUM_PROFILE_NAME}', *ARGV)
eos
        patched_binary.close
        execute_command("sudo mv #{patched_binary.path} #{FIREFOX_FOR_SELENIUM_BINARY}")  
        execute_command("sudo chmod +x #{FIREFOX_FOR_SELENIUM_BINARY}")
        execute_command("sudo chmod +x #{FIREFOX_FOR_SELENIUM_BINARY}")
        puts
      end
        
      def configure_old_firefox
        puts "This script will now open the patched copy of Firefox."
        puts
        puts "Please perform the following steps manually:"
        puts 
        puts "- Disable the default browser check when Firefox launches"
        puts "- Check that the version number is that of the old Firefox version you copied to #{FIREFOX_FOR_SELENIUM_PATH}"
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
        puts "    PATH=#{FIREFOX_FOR_SELENIUM_PATH}:$PATH cucumber"
        puts
        puts "Enjoy!" 
        puts
      end

      def run
        say_hello
        check_if_run_before
        download_old_firefox
        create_separate_profile # do this before the patching because the patched binary calls firefox with a profile that does not yet exist
        patch_old_firefox
        configure_old_firefox
        kkthxbb
      end
    
    end
  end
end

