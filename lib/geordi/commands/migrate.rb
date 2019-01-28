desc 'migrate', 'Migrate all databases'
long_desc <<-LONGDESC
Example: `geordi migrate`

If you are using `parallel_tests`, this runs migrations in your development
environment and `rake parallel:prepare` afterwards. Otherwise, invokes `geordi rake`
with `db:migrate`.
LONGDESC

def migrate
  invoke_cmd 'bundle_install'
  invoke_cmd 'yarn'
  announce 'Migrating'

  if File.directory?('db/migrate')
    if Util.file_containing?('Gemfile', /parallel_tests/)
      note 'Development and parallel test databases'
      puts

      Util.system! 'bundle exec rake db:migrate parallel:prepare'
    else
      invoke_cmd 'rake', 'db:migrate'
    end
  else
    note 'No migrations directory found.'
  end
end
