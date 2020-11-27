require 'geordi/interaction'
require 'yaml'

module Geordi
  class Docker
    DOCKER_COMPOSE_FILE = 'docker-compose.yml'.freeze

    include Interaction

    def setup
      check_installation_and_config
      announce('Building containers...')
      if execute(:system, 'docker-compose', 'build')
        success('Build successful.')
      else
        fail('Build failed.')
      end
    end

    def shell
      check_installation_and_config
      execute(:exec, 'docker-compose', 'run', '--service-ports', 'main')
    end

    private

    def execute(kind, *args)
      if ENV['GEORDI_TESTING']
        puts "Stubbed run #{args.join(' ')}"
        mock_run(*args)
      else
        send(kind, *args)
      end
    end

    def mock_run(*args)
      # exists just to be stubbed in tests
      true
    end

    def check_installation_and_config
      unless command_exists?('docker')
        fail('You need to install docker first with `sudo apt install docker`. After installation please log out and back in to your system once.')
      end

      unless command_exists?('docker-compose')
        fail('You need to install docker-compose first with `sudo apt install docker-compose`.')
      end

      unless docker_compose_config && (services = docker_compose_config['services']) && services.key?('main')
        fail('Your project does not seem to be properly set up. Expected to find a docker-compose.yml which defines a service named "main".')
      end
    end

    def command_exists?(command)
      execute(:system, "which #{command} > /dev/null")
    end

    def docker_compose_config
      if File.exists?(DOCKER_COMPOSE_FILE)
        if YAML.respond_to?(:safe_load)
          YAML.safe_load(File.read(DOCKER_COMPOSE_FILE))
        else
          YAML.load(File.read(DOCKER_COMPOSE_FILE))
        end
      end
    rescue
      false
    end
  end
end
