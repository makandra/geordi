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
end
