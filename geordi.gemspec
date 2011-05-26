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
  s.summary     = 'Collection of command line tools used in our daily work with Ruby, Rails and Linux.'
  s.description = 'Collection of command line tools used in our daily work with Ruby, Rails and Linux.'

  s.rubyforge_project = "geordi"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
