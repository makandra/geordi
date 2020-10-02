Before('@ruby>=2.1') do |scenario|
  skip_this_scenario if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.1')
end
