RSpec.describe Geordi::LinearClient do

  describe '#filter_existing_issue_ids' do
    it 'returns only issue ids that are also present in linear' do
      # override spec_helper default to test actual filtering logic.
      # This is okay here because we mock the actual API call
      allow(Geordi::Util).to receive(:testing?).and_return(false)

      linear_issues = [{ 'identifier' => 'W-123' }, { 'identifier' => 'W-234' }]
      allow(subject).to receive(:fetch_linear_issues).and_return(linear_issues)

      expect(subject.filter_existing_issue_ids(%w[W-123 W-234 W-345 A-123])).to eq %w[W-123 W-234]
    end
  end

  describe '.extract_issue_ids' do
    it 'returns extracted issue ids (only from the beginning of the commit message to avoid false matches)' do
      commit_messages = ["first example commit", "[W-365] Linear Issue Commit", "Commit with id [A-123] that gets ignored"]
      expect(described_class.extract_issue_ids(commit_messages)).to eq ["W-365"]
    end
  end

  describe '.filter_by_issue_ids' do
    it 'returns all commits starting with any given linear issue id' do
      commit_messages = ["first example commit", "[W-365] Linear Issue Commit", "Commit with id [W-365] that gets ignored", "[W-366] Linear Issue Commit 2"]
      relevant_ids = %w[W-365 W-366]
      expect(described_class.filter_by_issue_ids(commit_messages, relevant_ids)).to eq  ["[W-365] Linear Issue Commit", "[W-366] Linear Issue Commit 2"]
    end
  end

end
