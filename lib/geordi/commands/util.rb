require 'bundler'

module Geordi
  module Util

    private

    def system!(*commands)
      options = commands.last.is_a?(Hash) ? commands.pop : {}

      # Remove the gem's Bundler environment when running commands.
      Bundler.clean_system(*commands) or fail(options[:fail_message] || 'Something went wrong.')
    end

    def file_containing?(file, regex)
      File.exists?(file) and File.read(file).scan(regex).any?
    end

    # fix weird implementation of #invoke
    def invoke(name, task=nil, args = [], opts = {}, config=nil)
      super(name, task, args, opts, config)
    end

  end
end
