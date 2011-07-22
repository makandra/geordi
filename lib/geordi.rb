module Geordi
  
  attr_accessor :stage, :user, :server, :path, :env, :root
  
  def catching_errors(&block)
    begin
      yield
    rescue Exception => e
      $stderr.puts e.message
      exit 1
    end
  end
  
  def retrieve_data!
    @stage = ARGV.shift
    @root   = find_project_root!
    
    {}.tap do |data|
      @lines = if stage
        deploy_file = Dir['config/deploy/*.rb'].find do |file|
          file.match(/\/#{stage}.rb$/)
        end
        deploy_file or raise "Stage does not exist: #{stage}"
    
        File.open(deploy_file).readlines
      else
        []
      end
      @lines += File.open("config/deploy.rb").readlines
    
      @user   = retrieve! "user", /^set :user,/
      @server = retrieve! "server", /^server /
      @path   = retrieve!("deploy_to", /^set :deploy_to,/) + '/current'
      @env    = retrieve! "environment", /^set :rails_env,/
    
      # fix
      %w[user server path env].each do |attr|
        self.send(attr).gsub! /#\{site_id\}/, stage.sub(/_.*/, '')
      end
    end
  end
  
  def find_project_root!
    current = Dir.pwd
    until (File.exists? 'Capfile')
      Dir.chdir '..'
      raise 'Call me from inside a Rails project!' if current == Dir.pwd
      current = Dir.pwd
    end
    current
  end
  
  def retrieve!(name, regex)
    if line = @lines.find{ |line| line =~ regex }
      line.match(/["'](.*)["']/)
      $1
    else
      raise "Could not find :#{name} for stage '#{stage}'!\nAborting..."
    end
  end
  
end