desc 'update', 'Bring a project up to date'
long_desc <<-LONGDESC
Example: `geordi update`

Performs: `git pull`, `bundle install` (if necessary) and migrates (if applicable).
LONGDESC

option :dump, type: :string, aliases: '-d', banner: 'TARGET',
  desc: 'After updating, dump the TARGET db and source it into the development db'
option :test, type: :boolean, aliases: '-t', desc: 'After updating, run tests'

def update
  old_ruby_version = File.read('.ruby-version').chomp

  Interaction.announce 'Updating repository'
  Util.run!('git pull', show_cmd: true)

  ruby_version = File.read('.ruby-version').chomp
  ruby_version_changed = !ruby_version.empty? && (ruby_version != old_ruby_version)

  if ruby_version_changed
    puts
    Interaction.warn 'Ruby version changed during git pull. Please run again to use the new version.'
    exit(1)
  else
    invoke_geordi 'migrate'

    Interaction.success 'Successfully updated the project.'

    Hint.did_you_know [
      :setup
    ] unless options.dump || options.test

    invoke_geordi 'dump', options.dump, load: true if options.dump
    invoke_geordi 'tests' if options.test
  end

end
