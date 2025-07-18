RSpec.describe Geordi::Settings do
  describe '.normalize_team_ids' do
    it 'does not break Linear Team IDs if they are given as comma seperated String' do
      team_ids = "105be97c-924d,47a3-82feba8,456bc-defgh"
      normalized_team_ids = %w[105be97c-924d 47a3-82feba8 456bc-defgh]
      expect(described_class.new.send(:normalize_team_ids, team_ids)).to eq normalized_team_ids
    end

    it 'does not break Linear Team IDs if they are given as semicolon seperated String' do
      team_ids = "105be97c-924d;47a3-82feba8;456bc-defgh"
      normalized_team_ids = %w[105be97c-924d 47a3-82feba8 456bc-defgh]
      expect(described_class.new.send(:normalize_team_ids, team_ids)).to eq normalized_team_ids
    end

    it 'does not break Linear Team IDs if the given String contains extra whitespace' do
      team_ids = "105be97c-924d \t 47a3-82feba8  456bc-defgh"
      normalized_team_ids = %w[105be97c-924d 47a3-82feba8 456bc-defgh]
      expect(described_class.new.send(:normalize_team_ids, team_ids)).to eq normalized_team_ids
    end

    it "does not split up a single Linear Team ID" do
      team_id = "105be97c-924d-47a3-8ba9-282feba88393"
      normalized_team_id = ["105be97c-924d-47a3-8ba9-282feba88393"]
      expect(described_class.new.send(:normalize_team_ids, team_id)).to eq normalized_team_id
    end
  end


  describe '#irb_flags', type: :aruba do
    let(:global_settings_file_path) { File.expand_path('./tmp/global_settings.yml') }
    let(:local_settings_file_path) { File.expand_path('./tmp/local_settings.yml') }

    before do
      FileUtils.mkdir_p(File.dirname(global_settings_file_path))
      FileUtils.mkdir_p(File.dirname(local_settings_file_path))
    end

    after do
      FileUtils.rm_f(global_settings_file_path)
      FileUtils.rm_f(local_settings_file_path)
    end

    it 'uses the local settings if present' do
      write_file(global_settings_file_path, 'irb_flags: --no-readline')
      write_file(local_settings_file_path, 'irb_flags: --readline')

      expect(described_class.new.irb_flags).to eq ["--readline", :local]
    end

    it 'uses the local settings if present, even if they are empty' do
      write_file(global_settings_file_path, 'irb_flags: --no-readline')
      write_file(local_settings_file_path, 'irb_flags: ')

      expect(described_class.new.irb_flags).to eq ["", :local]
    end

    it "uses the global settings if local settings do not define irb_flags" do
      write_file(global_settings_file_path, 'irb_flags: --no-readline')
      write_file(local_settings_file_path, 'auto_update_chromedriver: true')

      expect(described_class.new.irb_flags).to eq ['--no-readline', :global]
    end

    it "can handle multiple flags" do
      write_file(local_settings_file_path, 'irb_flags: --readline --noinspect')

      expect(described_class.new.irb_flags).to eq ["--readline --noinspect", :local]
    end

    it "returns nil if neither global nor local settings define irb_flags" do
      write_file(global_settings_file_path, 'auto_update_chromedriver: false')
      write_file(local_settings_file_path, 'auto_update_chromedriver: true')

      expect(described_class.new.irb_flags).to be_nil
    end

    it "returns nil if neither global nor local settings exist" do
      expect(File.exist?(global_settings_file_path)).to be false
      expect(File.exist?(local_settings_file_path)).to be false

      expect(described_class.new.irb_flags).to be_nil
    end
  end
end
