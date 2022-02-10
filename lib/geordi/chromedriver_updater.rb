require 'open3'
require 'net/http'
require 'tempfile'

module Geordi
  class ChromedriverUpdater

    def run(options)
      chrome_version = determine_chrome_version
      current_chromedriver_version = determine_chromedriver_version

      latest_chromedriver_version = latest_version(chrome_version)
      if current_chromedriver_version == latest_chromedriver_version
        Interaction.success "No update required: Chromedriver is already on the latest version v#{latest_chromedriver_version}!" unless options[:quiet_if_matching]
      else
        update_chromedriver(latest_chromedriver_version)
      end
    end

    private

    def determine_chrome_version
      stdout_str, _error_str, status = Open3.capture3('google-chrome', '--version')
      chrome_version = unless stdout_str.nil?
        stdout_str[/\AGoogle Chrome ([\d.]+)/, 1]
      end

      if !status.success? || chrome_version.nil?
        Interaction.fail('Could not determine the version of Google Chrome.')
      else
        chrome_version
      end
    end

    def determine_chromedriver_version
      return unless Open3.capture2('which chromedriver')[1].success?

      stdout_str, _error_str, status = Open3.capture3('chromedriver', '-v')
      chromedriver_version = unless stdout_str.nil?
        stdout_str[/\AChromeDriver ([\d.]+)/, 1]
      end

      if !status.success? || chromedriver_version.nil?
        Interaction.fail('Could not determine the version of chromedriver.')
      else
        chromedriver_version
      end
    end

    # Check https://groups.google.com/a/chromium.org/g/chromium-discuss/c/4BB4jmsRyv8/m/TY3FXS4HBgAJ
    # for information how chrome version numbers work
    def major_version(full_version)
      full_version.match(/^(\d+\.\d+\.\d+)\.\d+$/)[1]
    end

    def update_chromedriver(latest_chromedriver_version)
      chromedriver_zip = download_chromedriver(latest_chromedriver_version)

      unzip(chromedriver_zip, File.expand_path('~/bin'))

      # We need to determine the version again, as it could be nil in case no chromedriver was installed before
      Interaction.success "Chromedriver updated to v#{determine_chromedriver_version}."
    end

    def download_chromedriver(latest_version)
      uri = URI("https://chromedriver.storage.googleapis.com/#{latest_version}/chromedriver_linux64.zip")
      response = Net::HTTP.get_response(uri)

      if response.is_a?(Net::HTTPSuccess)
        file = Tempfile.new(['chromedriver', '.zip'])
        file.write(response.body)

        file
      else
        Interaction.fail("Could not download chromedriver v#{latest_version}.")
      end
    end

    def latest_version(chrome_version)
      return @latest_version if @latest_version

      uri = URI("https://chromedriver.storage.googleapis.com/LATEST_RELEASE_#{major_version(chrome_version)}")
      response = Net::HTTP.get_response(uri)

      if response.is_a?(Net::HTTPSuccess)
        @latest_version = response.body.to_s
      else
        Interaction.fail("Could not download the chromedriver v#{chrome_version}.")
      end
    end

    def unzip(zip, output_dir)
      _stdout_str, _error_str, status = Open3.capture3('unzip', '-d', output_dir, '-o', zip.path)

      unless status.success?
        Interaction.fail("Could not unzip #{zip.path}.")
      end
    end
  end
end
