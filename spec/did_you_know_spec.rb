RSpec.describe Geordi::Hint do

  subject { Geordi::Hint }

  describe '#did_you_know' do
    before { allow_any_instance_of(Geordi::Settings).to receive(:hint_probability).and_return(100) }

    it 'generates hints from its arguments and prints one of them to stdout' do
      array = [
        :branch,
        [:branch, :from_master],
        'Custom message',
      ]

      expect {subject.did_you_know(array)}.to output(/Did you know\? (`geordi branch( -m)?`|Custom message)/).to_stdout
      expect(subject.did_you_know(array)).to eq([
        'Did you know? `geordi branch` can check out a feature branch based on an issue from Linear.',
        'Did you know? `geordi branch -m` can branch from master instead of the current branch.',
        'Did you know? Custom message',
      ])
    end
  end

end
