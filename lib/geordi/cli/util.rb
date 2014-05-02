require 'bundler'

module Geordi
  module Util

    private

    def system!(*commands)
      # Remove the gem's Bundler environment when running command.
      Bundler.clean_system(*commands) or fail
    end

    def file_containing?(file, regex)
      File.exists?(file) and File.read(file).scan(regex).any?
    end

  end
end
