require 'cucumber/rspec/doubles'


if Gem::Version.new(RUBY_VERSION) > Gem::Version.new('1.8.7')
  require 'pry'
end

# Disables execution of Util.system! calls
ENV['GEORDI_TESTING'] = 'true'
