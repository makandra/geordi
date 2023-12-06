require 'fileutils'

RSpec.describe Geordi::DBCleaner do
  describe '#new' do
    let(:dir) { File.join(Dir.pwd, 'tmp') }

    before do
      stub_const('ENV', ENV.to_hash.merge('XDG_CONFIG_HOME' => dir))
    end

    after do
      file_dir = File.join(dir, '/.config')
      FileUtils.rm_rf(file_dir)
    end

    it 'moves the legacy allowlists from ~/.config/geordi/whitelists to ~/.config/geordi/allowlists' do
      old_directory_path = "#{dir}/.config/geordi/whitelists/"
      old_file_path_postgres = "#{dir}/.config/geordi/whitelists/postgres.txt"
      old_file_path_mysql = "#{dir}/.config/geordi/whitelists/mysql.txt"
      new_file_path_postgres = "#{dir}/.config/geordi/allowlists/postgres.txt"
      new_file_path_mysql = "#{dir}/.config/geordi/allowlists/mysql.txt"

      FileUtils.mkdir_p(old_directory_path)
      File.open(old_file_path_postgres, 'w') do |file|
        file.write 'this is the allowlist for postgres'
      end

      File.open(old_file_path_mysql, 'w') do |file|
        file.write 'this is the allowlist for mysql'
      end

      expect(File.exist?(new_file_path_postgres)).to be false
      expect(File.exist?(new_file_path_mysql)).to be false

      Geordi::DBCleaner.new({})

      expect(File.exist?(new_file_path_postgres)).to be true
      expect(File.exist?(new_file_path_mysql)).to be true
      expect(File.read(new_file_path_postgres)).to eq 'this is the allowlist for postgres'
      expect(File.read(new_file_path_mysql)).to eq 'this is the allowlist for mysql'

      expect(File.exist?(old_file_path_postgres)).to be false
      expect(File.exist?(old_file_path_mysql)).to be false
    end

    it 'creates an allowlist directory if none exists' do
      allowlist_directory = "#{dir}/.config/geordi/allowlists"

      Geordi::DBCleaner.new({})

      expect(File.exist?(allowlist_directory)).to be true
    end

    it 'does not create or remove any directory if the allowlist directory already exists and is correctly named' do
      allowlist_directory_path = "#{dir}/.config/geordi/allowlists"
      FileUtils.mkdir_p(allowlist_directory_path)

      expect(FileUtils).to_not receive(:mkdir_p)
      expect(FileUtils).to_not receive(:mv)
      expect(Dir).to_not receive(:delete)

      Geordi::DBCleaner.new({})
    end

  end

end
