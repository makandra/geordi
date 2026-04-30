RSpec.describe Geordi::Util do
  describe '.rspec_path?' do
    it 'returns true if given a spec path or spec filename' do
      %w[
        spec
        spec/
        foo_spec.rb
        foo_spec.rb:123
        tests/foo_spec.rb
      ].each do |path|
        expect(described_class.rspec_path?(path)).to be true
      end
    end


    it 'returns false if given argument is not a spec path or filename' do
      %w[
        rspec
        foo.rb
        tests/foo.rb
        foo_spec_test.rb
        foo.feature
        features/foo.feature
      ].each do |path|
        expect(described_class.rspec_path?(path)).to be false
      end
    end

  end

  describe '.cucumber_path?' do
    it 'returns true if given a cucumber path or cucumber filename' do
      %w[
        features
        features/
        foo.feature
        foo.feature:123
        tests/foo.feature:234
      ].each do |path|
        expect(described_class.cucumber_path?(path)).to be true
      end
    end


    it 'returns false if given argument is not a cucumber path or filename' do
      %w[
        cucumber
        foo.rb
        tests/foo.rb
        foo_feature.rb
        foo_spec.rb
        spec
        spec/foo_spec.rb
      ].each do |path|
        expect(described_class.cucumber_path?(path)).to be false
      end
    end

  end

  describe '.determine_issues_to_move' do
    let(:source_branch) { 'feature/W-123-my-feature' }
    let(:target_branch) { 'master' }
    let(:target_stage) { 'staging' }

    it 'returns Linear issue IDs and relevant commits since the deployed revision' do
      allow(Geordi::Git).to receive(:commits_between).and_return([
        '[W-123] Implement feature',
        'Fix typo without issue',
      ])

      issue_ids, relevant_commits = described_class.determine_issues_to_move(source_branch, target_branch, target_stage)
      expect(issue_ids).to eq(['W-123'])
      expect(relevant_commits).to eq(['[W-123] Implement feature'])
    end

    it 'fails when no revision can be read from servers' do
      allow(Geordi::CapistranoConfig).to receive(:current_app_revisions).and_return([])

      expect(Geordi::Interaction).to receive(:fail).with('Could not read a server revision from app:revision output.')
      described_class.determine_issues_to_move(source_branch, target_branch, target_stage)
    end

    it 'returns empty arrays, warns and asks for confirmation when deployed revision differs across servers' do
      allow(Geordi::CapistranoConfig).to receive(:current_app_revisions).and_return(['abc123', 'def456'])
      allow(Geordi::Interaction).to receive(:confirm_or_cancel)

      expect(Geordi::Interaction).to receive(:warn).with('Currently deployed revision differs on servers.')
      expect(Geordi::Interaction).to receive(:confirm_or_cancel).with('Continue deployment without moving Linear issues?')
      issue_ids, relevant_commits = described_class.determine_issues_to_move(source_branch, target_branch, target_stage)
      expect(issue_ids).to eq([])
      expect(relevant_commits).to eq([])
    end

    it 'warns and falls back to commits between branches when the app:revision task is missing' do
      allow(Geordi::CapistranoConfig).to receive(:task_defined?).and_return(false)
      allow(Geordi::Git).to receive(:commits_between).and_return([
        '[W-456] Another feature',
        'Commit without issue',
      ])

      expect(Geordi::Interaction).to receive(:warn).with('Missing Capistrano task "app:revision". See `geordi help deploy`.')
      issue_ids, relevant_commits = described_class.determine_issues_to_move(source_branch, target_branch, target_stage)
      expect(issue_ids).to eq(['W-456'])
      expect(relevant_commits).to eq(['[W-456] Another feature'])
    end

  end

  describe '.console_command', type: :aruba do
    let(:global_settings_file_path) { File.expand_path('./tmp/global_settings.yml') }
    let(:local_settings_file_path) { File.expand_path('./tmp/local_settings.yml') }

    around do |example|
      original_ruby = ENV['GEORDI_TESTING_RUBY_VERSION']
      original_irb = ENV['GEORDI_TESTING_IRB_VERSION']

      FileUtils.mkdir_p(File.dirname(global_settings_file_path))
      FileUtils.mkdir_p(File.dirname(local_settings_file_path))

      example.run

      FileUtils.rm_f(global_settings_file_path)
      FileUtils.rm_f(local_settings_file_path)

      ENV["GEORDI_TESTING_RUBY_VERSION"] = original_ruby
      ENV["GEORDI_TESTING_IRB_VERSION"] = original_irb
    end

    context "no irb_flags in geordi config files" do
      it "does not automatically set --nomultiline option for Ruby 3+" do
        ENV['GEORDI_TESTING_RUBY_VERSION'] = '3.0.0'
        ENV['GEORDI_TESTING_IRB_VERSION'] = "1.2.0"
        expect(described_class.console_command("development")).to eq "bundle exec rails console -e development "
      end

      it "does not automatically set --nomultiline option for IRB < 1.2" do
        ENV['GEORDI_TESTING_RUBY_VERSION'] = '2.7.4'
        ENV['GEORDI_TESTING_IRB_VERSION'] = "1.1.0"
        expect(described_class.console_command("development")).to eq "bundle exec rails console -e development "
      end

      it "automatically sets --nomultiline option for IRB 1.2+ Ruby <3, to mitigate slow pasting" do
        ENV['GEORDI_TESTING_RUBY_VERSION'] = '2.7.4'
        ENV['GEORDI_TESTING_IRB_VERSION'] = "1.2.0"
        expect(described_class.console_command("development")).to eq "bundle exec rails console -e development -- --nomultiline"
      end
    end

    context "irb_flags in global geordi config file" do
      it "automatically sets --nomultiline option for IRB 1.2+ Ruby <3, to mitigate slow pasting and merges flags from config" do
        write_file(global_settings_file_path, 'irb_flags: --no-readline')
        ENV['GEORDI_TESTING_RUBY_VERSION'] = '2.7.4'
        ENV['GEORDI_TESTING_IRB_VERSION'] = "1.2.0"
        expect(described_class.console_command("development")).to eq "bundle exec rails console -e development -- --nomultiline --no-readline"
      end
    end

    context "irb_flags in local geordi config file" do
      it "does not automatically set --nomultiline option for IRB 1.2+ Ruby <3" do
        write_file(local_settings_file_path, 'irb_flags: --no-readline')
        ENV['GEORDI_TESTING_RUBY_VERSION'] = '2.7.4'
        ENV['GEORDI_TESTING_IRB_VERSION'] = "1.2.0"
        expect(described_class.console_command("development")).to eq "bundle exec rails console -e development -- --no-readline"
      end

      it "does not automatically set --nomultiline option for IRB 1.2+ Ruby <3 even with empty irb_flags" do
        write_file(local_settings_file_path, 'irb_flags:')
        ENV['GEORDI_TESTING_RUBY_VERSION'] = '2.7.4'
        ENV['GEORDI_TESTING_IRB_VERSION'] = "1.2.0"
        expect(described_class.console_command("development")).to eq "bundle exec rails console -e development "
      end
    end

    context "remote console" do
      it "does not automatically set --nomultiline option for Ruby 3+" do
        ENV['GEORDI_TESTING_RUBY_VERSION'] = '3.0.0'
        ENV['GEORDI_TESTING_IRB_VERSION'] = "1.2.0"
        expect(described_class.console_command("staging")).to eq "bundle exec rails console -e staging "
      end

      it "does not automatically set --nomultiline option for IRB < 1.2" do
        ENV['GEORDI_TESTING_RUBY_VERSION'] = '2.7.4'
        ENV['GEORDI_TESTING_IRB_VERSION'] = "1.1.0"
        expect(described_class.console_command("staging")).to eq "bundle exec rails console -e staging "
      end

      it "automatically sets --nomultiline option for IRB 1.2+ Ruby <3, to mitigate slow pasting" do
        ENV['GEORDI_TESTING_RUBY_VERSION'] = '2.7.4'
        ENV['GEORDI_TESTING_IRB_VERSION'] = "1.2.0"
        expect(described_class.console_command("staging")).to eq "bundle exec rails console -e staging -- --nomultiline"
      end

      it "does not automatically set --nomultiline option, but uses irb_flags from local config file" do
        write_file(local_settings_file_path, 'irb_flags: --no-readline')
        ENV['GEORDI_TESTING_RUBY_VERSION'] = '2.7.4'
        ENV['GEORDI_TESTING_IRB_VERSION'] = "1.2.0"
        expect(described_class.console_command("staging")).to eq "bundle exec rails console -e staging -- --no-readline"
      end

      it "does not automatically set --nomultiline option, but uses irb_flags from global config file" do
        write_file(local_settings_file_path, 'irb_flags: --no-readline')
        ENV['GEORDI_TESTING_RUBY_VERSION'] = '2.7.4'
        ENV['GEORDI_TESTING_IRB_VERSION'] = "1.2.0"
        expect(described_class.console_command("staging")).to eq "bundle exec rails console -e staging -- --no-readline"
      end
    end

  end

end
