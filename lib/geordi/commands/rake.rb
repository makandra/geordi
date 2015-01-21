desc 'rake TASK', 'Run a rake task in all Rails environments'
def rake(*args)
  for env in %w[development test cucumber performance]
    if File.exists? "config/environments/#{env}.rb"
      call = %w[bundle exec rake] + args + ["RAILS_ENV=#{env}"]
      note_cmd call.join(' ')

      Util.system! *call
    end
  end
end
