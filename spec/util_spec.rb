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

  describe '.extract_linear_issue_id' do
    it 'returns extracted issue ids from the beginning of the commit message' do
      commit_messages = ["first example commit", "[W-365] Linear Issue Commit", "Commit with id [A-123] that gets ignored"]
      expect(described_class.extract_linear_issue_ids(commit_messages)).to eq  ["W-365"]
    end
  end
end
