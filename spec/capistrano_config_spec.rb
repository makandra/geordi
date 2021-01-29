describe Geordi::CapistranoConfig, type: :aruba do
  subject do
    Geordi::CapistranoConfig.new('staging', Dir.getwd + '/tmp/aruba')
  end

  describe '#load_deploy_info' do
    before { write_file('Capfile', '# Configure your capistrano tasks') }

    it 'merges te deploy file for the specified stage into the config/deploy.rb file' do
      deploy_file = 'config/deploy.rb'
      staging_deploy_file = 'config/deploy/staging.rb'

      write_file(deploy_file, <<-TEXT)
        set :deploy_to, 'var/www.foobar.com'
      TEXT

      write_file(staging_deploy_file, <<-TEXT)
        set :rails_env, 'staging'
        set :deploy_to, '/var/www/example.com'
        set :user, 'user'

        server 'www.example.com'
      TEXT

      expect(deploy_file).to be_an_existing_file
      expect(staging_deploy_file).to be_an_existing_file
      deploy_info = subject.send(:load_deploy_info)

      expect(deploy_info).to eq(<<-TEXT)
        set :rails_env, 'staging'
        set :deploy_to, '/var/www/example.com'
        set :user, 'user'

        server 'www.example.com'

        set :deploy_to, 'var/www.foobar.com'
      TEXT
    end

  end

  describe '#user' do
    before { allow_any_instance_of(Geordi::CapistranoConfig).to receive(:load_deploy_info) }

    it 'returns the user variable from the deploy info for the Capistrano 2 syntax' do
      expect(subject).to receive(:deploy_info).and_return <<-TEXT
        set :user, 'example_user'
      TEXT
      expect(subject.user('')).to eq('example_user')
    end

    it 'returns the user variable from the deploy info for the Capistrano 3 syntax, if a server is given' do
      expect(subject).to receive(:deploy_info).twice.and_return <<-TEXT
        server 'www.example-server-one.de', user: 'example_user'
      TEXT
      expect(subject.user('www.example-server-one.de')).to eq('example_user')
    end

    it 'prefers the Caistrano 2 Syntax over the Capistrano 3 Syntax' do
      expect(subject).to receive(:deploy_info).and_return <<-TEXT
        server 'www.example-server-one.de', user: 'example_user_one'
        set :user, 'example_user_two'
      TEXT
      expect(subject.user('www.example-server-one.de')).to eq('example_user_two')
    end

    it 'returns nil if there is no user set with neither' do
      expect(subject).to receive(:deploy_info).twice.and_return ''
      expect(subject.user('')).to be_nil
    end

  end


  describe '#servers' do
    before { allow_any_instance_of(Geordi::CapistranoConfig).to receive(:load_deploy_info) }

    it 'scans the deploy info for servers and returns them as an array' do
      expect(subject).to receive(:deploy_info).and_return <<-TEXT
        server 'www.example-server-one.de', :app, :web, :db
        server 'www.example-server-two.de', :app, :web
      TEXT
      expect(subject.servers).to match_array(%w[www.example-server-one.de www.example-server-two.de])
    end

    it 'returns an empty array if no server is found' do
      expect(subject).to receive(:deploy_info).and_return ''
      expect(subject.servers).to match_array([])
    end

  end

  describe 'remote_root' do
    before { allow_any_instance_of(Geordi::CapistranoConfig).to receive(:load_deploy_info) }

    it 'returns "current" concatenated to the deploy_to variable from the deploy info' do
      expect(subject).to receive(:deploy_info).and_return <<-TEXT
        set :deploy_to, 'var/www/example_server'
      TEXT
      expect(subject.remote_root).to eq('var/www/example_server/current')
    end

    it 'returns nil if no deploy_to variable is found' do
      expect(subject).to receive(:deploy_info).and_return ''
      expect { subject.remote_root }.to raise_error(TypeError, 'no implicit conversion of nil into String')
    end

  end

  describe '#env' do
    before { allow_any_instance_of(Geordi::CapistranoConfig).to receive(:load_deploy_info) }

    it 'returns the first found rails_env variable in the deploy info' do
      expect(subject).to receive(:deploy_info).and_return <<-TEXT
        set :rails_env, 'staging'
        set :rails_env, 'production'
      TEXT
      expect(subject.env).to eq('staging')
    end

    it 'returns nil if there is no rails_env variable in the deploy info' do
      expect(subject).to receive(:deploy_info).and_return ''
      expect(subject.env).to be_nil
    end

  end
end
