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

      it 'handles offline errors' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError, 'Failed to open TCP connection to googlechromelabs.github.io:443 (getaddrinfo: Temporary failure in name resolution)')
        expect(Geordi::Interaction).to receive(:warn).with('Request failed: Failed to open TCP connection to googlechromelabs.github.io:443 (getaddrinfo: Temporary failure in name resolution)')

        subject.run(exit_on_failure: false)
      end
    end
  end
end
