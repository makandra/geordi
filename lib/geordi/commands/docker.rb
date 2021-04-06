class DockerCLI < Thor
  desc 'setup', 'Setup docker and fetch required docker-container for the current project'
  def setup
    docker.setup
  end

  desc 'shell', 'Open a shell in the main docker container for the current project'
  option :secondary, default: false, type: :boolean
  map 'shell' => '_shell'
  def _shell
    docker.shell(:secondary => options[:secondary])
  end

  desc 'vnc', 'Open a vnc viewer connecting to the docker container'
  option :setup, default: false, type: :boolean, desc: 'Guide through the setup of VNC'
  def vnc
    if options.setup
      docker.setup_vnc
    else
      docker.vnc
    end
  end

  private

  def docker
    require 'geordi/docker'
    Geordi::Docker.new
  end
end

desc 'docker', 'Manage docker containers for the current project'
long_desc <<-LONGDESC
Manage docker containers to run your project dockerized.

It expects a `docker-compose.yml` file that specifies all services, and a service
named "main" that opens a shell for the project.

There are three subcommands:

- `geordi docker setup`
  Fetches all docker containers.

- `geordi docker shell`
  Runs the docker service named 'main'.
  Append `--secondary` to open a second shell in an already running container.

- `geordi docker vnc`
  Opens a VNC viewer to connect to the VNC server in the container.
  Append `--setup` to be guided through the setup of VNC viewer.
LONGDESC
subcommand 'docker', DockerCLI
