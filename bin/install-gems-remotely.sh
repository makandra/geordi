#!/bin/sh
if [ -z "$1" ]; then
  echo "Please specify the remote server name"
  exit 1
fi
mkdir -p tmp
if ls vendor/gems/*/*.gemspec > /dev/null 2>&1; then
  tar cf tmp/gemfiles_for_remote_install Gemfile Gemfile.lock vendor/gems
else
  tar cf tmp/gemfiles_for_remote_install Gemfile Gemfile.lock
fi
scp tmp/gemfiles_for_remote_install $1:~
stty_orig=`stty -g`
stty -echo
ssh -t $1 "mkdir /tmp/install_gems; mv gemfiles_for_remote_install /tmp/install_gems; cd /tmp/install_gems; tar xf gemfiles_for_remote_install; bundle install; rm -rf /tmp/install_gems"
stty $stty_orig
