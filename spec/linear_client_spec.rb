RSpec.describe Geordi::LinearClient do

  describe '.extract_issue_ids' do
    it 'returns extracted issue ids (only from the beginning of the commit message to avoid false matches)' do
      commit_messages = ["first example commit", "[W-365] Linear Issue Commit", "Commit with id [A-123] that gets ignored"]
      expect(described_class.extract_issue_ids(commit_messages)).to eq ["W-365"]
    end
  end

  describe '#filter_by_issue_ids' do
    it 'returns all commits starting with any given linear issue id' do
      commit_messages = ["first example commit", "[W-365] Linear Issue Commit", "Commit with id [W-365] that gets ignored", "[W-366] Linear Issue Commit 2"]
      relevant_ids = %w[W-365 W-366]
      expect(described_class.new.filter_by_issue_ids(commit_messages, relevant_ids)).to eq  ["[W-365] Linear Issue Commit", "[W-366] Linear Issue Commit 2"]
    end
  end

end
