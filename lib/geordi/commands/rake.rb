desc 'rake TASK', 'Run a rake task in several Rails environments'
long_desc <<-LONGDESC
Example: `geordi rake db:migrate`

TASK is run in the following Rails environments (if present):

- development
- test
- cucumber
LONGDESC

def rake(*args)
  for env in %w(development test cucumber) # update long_desc when changing this
    if File.exists? "config/environments/#{env}.rb"
      call = %w[bundle exec rake] + args + ["RAILS_ENV=#{env}"]
      note_cmd call.join(' ')

      Util.system! *call
    end
  end
end
