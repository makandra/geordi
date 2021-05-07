require 'open3'
require 'net/http'
require 'tempfile'

module Geordi
  class ChromedriverUpdater

    def run(options)
      chrome_version = determine_chrome_version
      chromedriver_version = determine_chromedriver_version

      if skip_update?(chrome_version, chromedriver_version)
        Interaction.success "No update required: both Chrome and chromedriver are on v#{chrome_version}!" unless options[:quiet_if_matching]
      else
        chromedriver_zip = download_chromedriver(chrome_version)
        unzip(chromedriver_zip, File.expand_path('~/bin'))

        chromedriver_zip.unlink

        # We need to determine the version again, as it could be nil in case no chromedriver was installed before
        Interaction.success "Chromedriver updated to v#{determine_chromedriver_version}."
      end
    end

    private

    def determine_chrome_version
      stdout_str, _error_str, status = Open3.capture3('google-chrome', '--version')
      chrome_version = unless stdout_str.nil?
        stdout_str[/\AGoogle Chrome (\d+)/, 1]
      end

      if !status.success? || chrome_version.nil?
        Interaction.fail('Could not determine the version of Google Chrome.')
      else
        chrome_version.to_i
      end
    end

    def determine_chromedriver_version
      return unless Open3.capture2('which chromedriver')[1].success?

      stdout_str, _error_str, status = Open3.capture3('chromedriver', '-v')
      chromedriver_version = unless stdout_str.nil?
        stdout_str[/\AChromeDriver (\d+)/, 1]
      end

      if !status.success? || chromedriver_version.nil?
        Interaction.fail('Could not determine the version of chromedriver.')
      else
        chromedriver_version.to_i
      end
    end

    def skip_update?(chrome_version, chromedriver_version)
      chrome_version == chromedriver_version
    end

    def download_chromedriver(chrome_version)
      latest_version = latest_version(chrome_version)

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
      uri = URI("https://chromedriver.storage.googleapis.com/LATEST_RELEASE_#{chrome_version}")
      response = Net::HTTP.get_response(uri)

      if response.is_a?(Net::HTTPSuccess)
        response.body.to_s
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
