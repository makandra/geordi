# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "geordi/version"

Gem::Specification.new do |s|
  s.name        = "geordi"
  s.version     = Geordi::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Henning Koch"]
  s.email       = ["henning.koch@makandra.de"]
  s.homepage    = "http://makandra.com"
  s.summary     = 'Collection of command line tools we use in our daily work with Ruby, Rails and Linux at makandra.'
  s.description = 'Collection of command line tools we use in our daily work with Ruby, Rails and Linux at makandra.'
  s.license     = 'MIT'

  s.rubyforge_project = "geordi"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'thor', '>= 0.19'
  s.add_runtime_dependency 'highline'
  s.add_runtime_dependency 'pivotal-tracker'
  s.add_runtime_dependency 'bundler'
  s.add_runtime_dependency 'erb'
  s.add_runtime_dependency 'yaml'
  s.add_runtime_dependency 'launchy'
  s.add_runtime_dependency 'capistrano'

  # s.add_development_dependency 'debugger'

  s.post_install_message = <<-ATTENTION

    ********************************************
    geordi 0.18.0 removes the following scripts:
      cuc, migrate-all, rs, tests

    Their functionality has moved to the geordi
    script. Run `geordi` and `geordi test help`
    for further information.

    To get them back, add the following aliases
    to your ~/.bashrc:

      alias cuc="geordi test cucumber"
      alias migrate-all="geordi migrate"
      alias rs="geordi test rspec"
      alias tests="geordi test all"
    ********************************************

  ATTENTION
end
