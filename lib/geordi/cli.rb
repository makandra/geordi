require 'thor'
require 'bundler'
require 'geordi/interaction'
require 'geordi/util'
require 'English'

module Geordi
  class CLI < Thor

    def self.exit_on_failure?
      true
    end

    # load all tasks defined in lib/geordi/commands
    Dir[File.expand_path 'commands/*.rb', __dir__].each do |file|
      class_eval File.read(file), file
    end

    private

    # fix weird implementation of #invoke
    def invoke_geordi(name, *args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      invoke(name, args, options)
    end

  end
end
