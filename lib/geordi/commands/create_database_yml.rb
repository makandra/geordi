desc 'create-database-yml', '[sic]', hide: true
def create_database_yml
  real_yml = 'config/database.yml'
  sample_yml = 'config/database.sample.yml'

  if File.exist?(sample_yml) && !File.exist?(real_yml)
    Interaction.announce 'Creating ' + real_yml

    sample = File.read(sample_yml)
    adapter = sample.match(/adapter: (\w+)/).captures.first

    print "Please enter your #{adapter} password: "
    db_password = STDIN.gets.strip

    real = sample.gsub(/password:.*$/, "password: #{db_password}")
    File.open(real_yml, 'w') { |f| f.write(real) }

    Interaction.note "Created #{real_yml}."
  end
end
