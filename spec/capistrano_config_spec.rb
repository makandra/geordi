RSpec.describe Geordi::CapistranoConfig, type: :aruba do
  before do
    write_file('Capfile', '# Configure your capistrano tasks')
    ENV['RAILS_ROOT'] = Dir.getwd + '/tmp/aruba'
  end

  subject do
    @stage ||= nil
    Geordi::CapistranoConfig.new(@stage)
  end

  describe '#load_deploy_info'do
    let(:deploy_info) { subject.send :load_deploy_info }

    it 'concats the stage config file with config/deploy.rb' do
      @stage = 'staging'
      deploy_file = 'config/deploy.rb'
      staging_deploy_file = 'config/deploy/staging.rb'

      write_file(deploy_file, <<-TEXT)
        content of config/deploy.rb
      TEXT

      write_file(staging_deploy_file, <<-TEXT)
        content of config/deploy/staging.rb
      TEXT

      expect(deploy_file).to be_an_existing_file
      expect(staging_deploy_file).to be_an_existing_file

      expect(deploy_info).to eq(<<-TEXT)
        content of config/deploy/staging.rb
        content of config/deploy.rb
      TEXT
    end

    it 'omits commented-out lines' do
      write_file 'config/deploy.rb', <<-DEPLOY
# comment
        # indented comment
        server 'app01.example.com', user: 'new_user' # trailing comment
        # server 'app02.example.com', user: 'old_user'
      DEPLOY

      expect(deploy_info).to eq <<-INFO
        server 'app01.example.com', user: 'new_user' # trailing comment
      INFO
    end

    it 'joins wrapped lines' do
      write_file 'config/deploy.rb', <<-DEPLOY
server 'app01.example.com',
  user: \
  'new_user'
      DEPLOY

      expect(deploy_info).to eq <<-INFO
server 'app01.example.com',  user: \  'new_user'
      INFO
    end
  end

  describe '#user' do
    it 'returns the user variable from the deploy info for the Capistrano 2 syntax' do
      write_file 'config/deploy.rb', <<-TEXT
        set :user, 'example_user'
      TEXT
      expect(subject.user('')).to eq('example_user')
    end

    it 'returns the user variable from the deploy info for the Capistrano 3 syntax, if a server is given' do
      write_file 'config/deploy.rb', <<-TEXT
        server 'www.example-server-one.de', user: 'example_user'
      TEXT
      expect(subject.user('www.example-server-one.de')).to eq('example_user')
    end

    it 'prefers the Capistrano 2 Syntax over the Capistrano 3 Syntax' do
      write_file 'config/deploy.rb', <<-TEXT
        server 'www.example-server-one.de', user: 'example_user_one'
        set :user, 'example_user_two'
      TEXT
      expect(subject.user('www.example-server-one.de')).to eq('example_user_two')
    end

    it 'ignores commented-out lines' do
      write_file 'config/deploy.rb', <<-TEXT
        server 'app01.example.com', user: 'new_user'
        # server 'app02.example.com', user: 'old_user'
      TEXT
      expect(subject.user('app01.example.com')).to eq('new_user')
    end

    it 'understands multiline server definitions' do
      write_file 'config/deploy.rb', <<-TEXT
        server 'app01.example.com',
          user: 'new_user'
      TEXT
      expect(subject.user('app01.example.com')).to eq('new_user')
    end

    it 'understands multiline server definitions including parentheses' do
      write_file 'config/deploy.rb', <<-TEXT
        server('app01.example.com',
          user: 'new_user'
        )
      TEXT
      expect(subject.user('app01.example.com')).to eq('new_user')
    end

    it 'returns nothing if there is no user set with neither' do
      write_file 'config/deploy.rb', ""
      expect(subject.user('')).to be_nil
    end
  end

  describe '#servers' do
    before { allow_any_instance_of(Geordi::CapistranoConfig).to receive(:load_deploy_info) }

    it 'scans the deploy info for servers and returns them as an array' do
      expect(subject).to receive(:deploy_info).and_return <<-TEXT
        server 'www.example-server-one.de', :app, :web, :db
        server 'www.example-server-two.de', :app, :web
        server('www.example-server-three.de', :app)
        server(
          'www.example-server-four.de',
          roles: [:app]
        )
      TEXT
      expect(subject.servers).to match_array(%w[
        www.example-server-one.de
        www.example-server-two.de
        www.example-server-three.de
        www.example-server-four.de
      ])
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
