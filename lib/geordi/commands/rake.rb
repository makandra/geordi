desc 'rake', 'Run rake in all Rails environments'
def rake(*args)
  for env in %w[development test cucumber performance]
    if File.exists? "config/environments/#{env}.rb"
      call = ['b', 'rake'] + args + ["RAILS_ENV=#{env}"]
      note call.join(' ')

      system *call
    end
  end
end
