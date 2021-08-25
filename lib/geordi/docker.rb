require 'geordi/interaction'
require 'geordi/cucumber'
require 'yaml'
require 'open3'

module Geordi
  class Docker
    DOCKER_COMPOSE_FILE = 'docker-compose.yml'.freeze

    include Interaction

    def setup
      check_installation_and_config
      announce('Fetching containers...')
      if execute(:system, 'docker-compose', 'pull')
        success('Fetch successful.')
      else
        fail('Fetch failed.')
      end
    end

    def shell(options = {})
      check_installation_and_config
      if options[:secondary]
        attach_to_running_shell
      else
        run_shell
      end
    end

    def vnc
      check_installation_and_config
      launch_vnc_viewer('::5967')
    end

    def setup_vnc
      `clear`
      Interaction.note 'This script will help you install a VNC viewer.'
      Interaction.note 'Please open a second shell to execute instructions.'
      Interaction.prompt 'Continue ...'

      Interaction.announce 'Setup VNC viewer'
      vnc_viewer_installed = system('which vncviewer > /dev/null 2>&1')
      if vnc_viewer_installed
        Interaction.success 'It appears you already have a VNC viewer installed. Good job!'
      else
        puts 'Please run:'
        Interaction.note_cmd 'sudo apt-get install xtightvncviewer'
        Interaction.prompt 'Continue ...'
      end

      puts
      puts <<~TEXT
        Done. You can view the VNC window with `geordi docker vnc`.
      TEXT

      Interaction.success 'Happy cuking!'
    end

    private

    def launch_vnc_viewer(source)
      fail('VNC viewer not found. Install it with `geordi docker vnc --setup`.') unless command_exists?('vncviewer')

      fork do
        error = capture_stderr do
          system("vncviewer #{source}")
        end
        unless $?.success?
          if $?.exitstatus == 127
            fail('VNC viewer not found. Install it with `geordi docker vnc --setup`.')
          else
            fail("VNC viewer could not be opened: #{error}")
          end
        end
      end
      exit 0
    end

    def attach_to_running_shell
      # The command line output of docker-compose ps changes depending on the container name length, this is
      # caused by the varying terminal length and results in the longer outputs, e.g the container name and id
      # to be cut after x characters and the rest being placed in the line below.

      stdout_str, _error_str = execute(:capture, {'COLUMNS' => '400'}, 'docker-compose ps')
      running_containers = stdout_str.split("\n")
      if (main_container_line = running_containers.grep(/_main_run/).first)
        container_name = main_container_line.split(' ').first
        execute(:exec, 'docker', 'exec', '-it', container_name, 'bash')
      else
        fail('Could not find a running shell. Start without --secondary first.')
      end
    end

    def run_shell
      command = [:system, 'docker-compose', 'run', '--service-ports']
      command += ssh_agent_forward
      command += ['main']
      execute(*command)
      execute(:system, 'docker-compose', 'stop')
    end

    def execute(kind, *args)
      if ENV['GEORDI_TESTING']
        puts "Stubbed run #{args.join(' ')}"
        if kind == :` || kind == :capture
          mock_parse(*args)
        else
          mock_run(*args)
        end
      else
        if kind == :capture
          Open3.capture2(*args)
        else
          send(kind, *args)
        end
      end
    end

    def mock_run(*args)
      # exists just to be stubbed in tests
      true
    end

    def mock_parse(*args)
      # exists just to be stubbed in tests
      'command output'
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
      @docker_compose_config ||= if File.exists?(DOCKER_COMPOSE_FILE)
        if YAML.respond_to?(:safe_load)
          YAML.safe_load(File.read(DOCKER_COMPOSE_FILE))
        else
          YAML.load(File.read(DOCKER_COMPOSE_FILE))
        end
      end
    rescue
      false
    end

    def ssh_agent_forward
      if (auth_sock = ENV['SSH_AUTH_SOCK'])
        dirname = File.dirname(auth_sock)
        ['-v', "#{dirname}:#{dirname}", '-e', "SSH_AUTH_SOCK=#{auth_sock}"]
      else
        []
      end
    end

    def capture_stderr
      old_stderr = $stderr.dup
      io = Tempfile.new('cuc')
      $stderr.reopen(io)
      yield
      io.rewind
      io.read
    ensure
      io.close
      io.unlink
      $stderr.reopen(old_stderr)
    end

  end
end
