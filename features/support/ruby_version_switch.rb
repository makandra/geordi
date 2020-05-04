Before('@ruby>=2.1') do |scenario|
  scenario.skip_invoke! if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.1')
end
