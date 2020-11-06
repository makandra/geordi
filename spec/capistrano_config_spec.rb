describe Geordi::CapistranoConfig, type: :aruba do
  subject do
    Geordi::CapistranoConfig.new('staging', Dir.getwd + '/tmp/aruba')
  end

  describe '#load_deploy_info' do
    before { write_file('Capfile', '# Configure your capistrano tasks') }

    it 'merges te deploy file for the specified stage into the config/deploy.rb file' do
      deploy_file = 'config/deploy.rb'
      staging_deploy_file = 'config/deploy/staging.rb'

      write_file(deploy_file, <<~TEXT)
        set :deploy_to, 'var/www.foobar.com'
      TEXT

      write_file(staging_deploy_file, <<~TEXT)
        set :rails_env, 'staging'
        set :deploy_to, '/var/www/example.com'
        set :user, 'user'

        server 'www.example.com'
      TEXT

      expect(deploy_file).to be_an_existing_file
      expect(staging_deploy_file).to be_an_existing_file
      deploy_info = subject.send(:load_deploy_info)

      expect(deploy_info).to eq(<<~TEXT)
        set :rails_env, 'staging'
        set :deploy_to, '/var/www/example.com'
        set :user, 'user'

        server 'www.example.com'

        set :deploy_to, 'var/www.foobar.com'
      TEXT
    end

  end

  describe
end
