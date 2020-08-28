desc 'migrate', 'Migrate all databases'
long_desc <<-LONGDESC
Example: `geordi migrate`

If you are using `parallel_tests`, this runs migrations in your development
environment and `rake parallel:prepare` afterwards. Otherwise, invokes `geordi rake`
with `db:migrate`.
LONGDESC

def migrate
  invoke_geordi 'bundle_install'
  invoke_geordi 'yarn_install'
  Interaction.announce 'Migrating'

  if File.directory?('db/migrate')
    if Util.file_containing?('Gemfile', /parallel_tests/)
      Interaction.note 'Development and parallel test databases'
      puts

      Util.system! Util.binstub('rake'), 'db:migrate', 'parallel:prepare'
    else
      invoke_geordi 'rake', 'db:migrate'
    end
  else
    Interaction.note 'No migrations directory found.'
  end
end
