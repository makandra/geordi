class DockerCLI < Thor
  desc 'setup', 'Setup docker and build required docker-container for the current project.'
  def setup
    docker.setup
  end

  desc 'shell', 'Open a shell in the main docker container for the current project.'
  map 'shell' => '_shell'
  def _shell
    docker.shell
  end

  private

  def docker
    require 'geordi/docker'
    Geordi::Docker.new
  end
end

desc 'docker', 'Manage docker containers for the current project.'
subcommand 'docker', DockerCLI
