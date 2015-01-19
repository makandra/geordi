desc 'version', 'Print the current version of geordi'
def version
  require 'geordi/version'
  puts 'Geordi ' + Geordi::VERSION
end
map '-v' => :version
map '--version' => :version
