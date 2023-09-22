require 'open3'
require 'net/http'
require 'tempfile'
require 'json'
require 'fileutils'

module Geordi
  class ChromedriverUpdater
    VERSIONS_PER_MILESTONES_URL = "https://googlechromelabs.github.io/chrome-for-testing/latest-versions-per-milestone-with-downloads.json"

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
    def milestone_version(full_version)
      full_version.match(/^\d+/)[0]
    end

    def update_chromedriver(latest_chromedriver_version)
      chromedriver_zip = download_chromedriver(latest_chromedriver_version)

      unzip(chromedriver_zip, File.expand_path('~/bin'))

      # We need to determine the version again, as it could be nil in case no chromedriver was installed before
      Interaction.success "Chromedriver updated to v#{determine_chromedriver_version}."
    end

    def download_chromedriver(version)
      fetch_response(chromedriver_url(version), "Could not download chromedriver v#{version}.") do |response|
        file = Tempfile.new(%w[chromedriver .zip])
        file.write(response.body)

        file
      end
    end

    def fetch_response(url, error_message)
      uri = URI(url)
      response = Net::HTTP.get_response(uri)

      if response.is_a?(Net::HTTPSuccess)
        yield(response)
      else
        Interaction.fail(error_message)
      end
    end

    def chromedriver_url(chrome_version)
        chromedriver_per_platform = chromedriver_download_data.dig("milestones", milestone_version(chrome_version), "downloads", "chromedriver")
        chromedriver = chromedriver_per_platform&.find do |chromedriver|
          chromedriver["platform"] == "linux64"
        end

        if chromedriver && chromedriver["url"]
          chromedriver["url"]
        else
          Interaction.fail("Could not find chromedriver download url for chrome version v#{chrome_version}")
        end
    end

    def chromedriver_download_data
      return @chromedriver_download_data if @chromedriver_download_data

      fetch_response(VERSIONS_PER_MILESTONES_URL, "Could not find chromedriver download data") do |response|
        begin
          chromedriver_download_data = JSON.parse(response.body)
        rescue JSON::ParserError
          Interaction.fail("Could not parse chromedriver download data")
        end
        @chromedriver_download_data = chromedriver_download_data
      end
    end

    def latest_version(chrome_version)
      latest_version = chromedriver_download_data.dig("milestones", milestone_version(chrome_version), "version")
      latest_version || Interaction.fail("Could not find matching chromedriver for chrome v#{chrome_version}")
    end

    def unzip(zip, output_dir)
      _stdout_str, _error_str, status = Open3.capture3('unzip', '-d', output_dir, '-o', zip.path)

      unless status.success?
        Interaction.fail("Could not unzip #{zip.path}.")
      end

      # the archive contains a folder in which the relevant files are located. These files must be moved to ~/bin.
      FileUtils.mv("#{output_dir}/chromedriver-linux64/chromedriver", output_dir)
      FileUtils.mv("#{output_dir}/chromedriver-linux64//LICENSE.chromedriver", output_dir)
      FileUtils.rm_rf("#{output_dir}/chromedriver-linux64")
    end
  end
end
