require 'thor'
require 'bundler'
require 'geordi/interaction'
require 'geordi/util'

module Geordi
  class CLI < Thor
    include Geordi::Interaction

    # load all tasks defined in lib/geordi/commands
    Dir[File.expand_path '../commands/*.rb', __FILE__].each do |file|
      class_eval File.read(file), file
    end

    private

    def file_containing?(file, regex)
      File.exists?(file) and File.read(file).scan(regex).any?
    end

    # fix weird implementation of #invoke
    def invoke_cmd(name, *args)
      options = args.pop if args.last.is_a?(Hash)
      invoke(name, args, options)
    end

  end
end
