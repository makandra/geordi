desc 'apache-site VIRTUAL_HOST', 'Enable the given virtual host, disabling all others'
def apache_site(*args)
  site = args.shift
  old_cwd = Dir.pwd
  Dir.chdir '/etc/apache2/sites-available/'

  # show available sites if no site was passed as argument
  unless site
    puts 'ERROR: Argument site is missing.'
    puts 'Please call: apache-site my-site'
    puts
    puts 'Available sites:'
    Dir.new(".").each do |file|
      puts "- #{file}" if file != '.' && file != '..'
    end
    exit
  end

  has_default = File.exists?('default')
  exec "sudo a2dissite \*; sudo a2ensite #{"default " if has_default}#{site} && sudo apache2ctl restart"
  Dir.chdir old_cwd
end
