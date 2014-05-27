desc 'create_database_yml', '[sic]', :hide => true
def create_database_yml
  real_yml = 'config/database.yml'
  sample_yml = 'config/database.sample.yml'

  if File.exists?(sample_yml) and not File.exists?(real_yml)
    announce 'Creating ' + real_yml

    print 'Please enter your DB password: '
    db_password = STDIN.gets.strip

    sample = File.read(sample_yml)
    real = sample.gsub(/password:.*$/, "password: #{db_password}")
    File.open(real_yml, 'w') { |f| f.write(real) }

    note "Created #{real_yml}."
  end
end
