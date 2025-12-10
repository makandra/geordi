require 'open3'
require 'net/http'
require 'tempfile'
require 'json'
require 'fileutils'

module Geordi
  class ChromedriverUpdater
    class ProcessingError < StandardError; end

    VERSIONS_PER_MILESTONES_URL = "https://googlechromelabs.github.io/chrome-for-testing/latest-versions-per-milestone-with-downloads.json"

    def run(options)
      chrome_version = determine_chrome_version
      current_chromedriver_version = determine_chromedriver_version

      latest_chromedriver_version = latest_version(chrome_version)
      if current_chromedriver_version == latest_chromedriver_version
        Interaction.note "No update required. Chromedriver is already on the latest version #{latest_chromedriver_version}." unless options[:quiet_if_matching]
      else
        update_chromedriver(latest_chromedriver_version)
      end

    rescue ProcessingError => e
      interaction_method = (options[:exit_on_failure] == false) ? :warn : :fail
      Interaction.public_send(interaction_method, e.message)
    end

    private

    def determine_chrome_version
      stdout_str, _error_str, status = Open3.capture3('google-chrome', '--version')
      chrome_version = unless stdout_str.nil?
        stdout_str[/\AGoogle Chrome ([\d.]+)/, 1]
      end

      if !status.success? || chrome_version.nil?
        raise ProcessingError, 'Could not determine the version of Google Chrome.'
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
        raise ProcessingError, 'Could not determine the version of chromedriver.'
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
      Interaction.success "Chromedriver updated to #{determine_chromedriver_version}."
    end

    def download_chromedriver(version)
      fetch_response(chromedriver_url(version), "Could not download chromedriver #{version}.") do |response|
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
        raise ProcessingError, error_message
      end

    # Rescue Errno::NOERROR, Errno::ENOENT, Errno::EACCES, Errno::EFAULT, Errno::ECONNREFUSED, Errno::ECONNABORTED, Errno::ECONNRESET, Errno::EHOSTDOWN, Errno::EHOSTUNREACH, ...,
    # all of which are a subclass of SystemCallError
    # and DNS / resolution errors (SocketError, including Socket::ResolutionError on 3.3+)
    rescue SystemCallError, SocketError => e
      raise ProcessingError, "Request failed: #{e.message}"
    end

    def chromedriver_url(chrome_version)
        chromedriver_per_platform = chromedriver_download_data.dig("milestones", milestone_version(chrome_version), "downloads", "chromedriver")
        chromedriver = chromedriver_per_platform&.find do |chromedriver|
          chromedriver["platform"] == "linux64"
        end

        if chromedriver && chromedriver["url"]
          chromedriver["url"]
        else
          raise ProcessingError, "Could not find chromedriver download url for Chrome #{chrome_version}."
        end
    end

    def chromedriver_download_data
      @chromedriver_download_data ||= begin
        fetch_response(VERSIONS_PER_MILESTONES_URL, "Could not find chromedriver download data") do |response|
          begin
            JSON.parse(response.body)
          rescue JSON::ParserError
            raise ProcessingError, "Could not parse chromedriver download data."
          end
        end
      end
    end

    def latest_version(chrome_version)
      latest_version = chromedriver_download_data.dig("milestones", milestone_version(chrome_version), "version")
      latest_version || raise(ProcessingError, "Could not find matching chromedriver for Chrome #{chrome_version}.")
    end

    def unzip(zip, output_dir)
      _stdout_str, _error_str, status = Open3.capture3('unzip', '-d', output_dir, '-o', zip.path)

      unless status.success?
        raise ProcessingError, "Could not unzip #{zip.path}."
      end

      # the archive contains a folder in which the relevant files are located. These files must be moved to ~/bin.
      FileUtils.mv("#{output_dir}/chromedriver-linux64/chromedriver", output_dir)
      FileUtils.mv("#{output_dir}/chromedriver-linux64//LICENSE.chromedriver", output_dir)
      FileUtils.rm_rf("#{output_dir}/chromedriver-linux64")
    end
  end
end
