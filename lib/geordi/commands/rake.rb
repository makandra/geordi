desc 'rake', 'Run rake in all Rails environments'
def rake(*args)
  for env in %w[development test cucumber performance]
    if File.exists? "config/environments/#{env}.rb"
      call = ['bundle exec rake'] + args + ["RAILS_ENV=#{env}"]
      note_cmd call.join(' ')

      system *call
    end
  end
end
