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

  s.add_runtime_dependency 'thor', '~> 0.18.0'

  s.post_install_message = <<-ATTENTION
* Binary `geordi` installed
  ATTENTION
end
