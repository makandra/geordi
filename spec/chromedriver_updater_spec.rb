RSpec.describe Geordi::ChromedriverUpdater do
  describe '#run' do
    context 'exit_on_failure=true (default)' do
      it 'exits the command with status code 1 if an error occurs' do
        allow(subject).to receive(:determine_chrome_version).and_raise(Geordi::ChromedriverUpdater::ProcessingError, 'The error message')
        expect(Geordi::Interaction).to receive(:fail).with('The error message')

        subject.run({})
      end
    end

    context 'exit_on_failure=false' do
      it 'only prints a warning if an error occurs' do
        allow(subject).to receive(:determine_chrome_version).and_raise(Geordi::ChromedriverUpdater::ProcessingError, 'The error message')
        expect(Geordi::Interaction).to receive(:warn).with('The error message')

        subject.run(exit_on_failure: false)
      end
    end
  end
end
