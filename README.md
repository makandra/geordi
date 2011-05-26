Geordi
=====

Geordi is a collection of command line tools we use in our daily work with Ruby, Rails and Linux at [makandra](http://makandra.com/).

Installing the `geordi` gem will link all included tools into your `/usr/bin`:

    sudo gem install geordi

Below you can find a list of all included tools.

apache-site
-----------

Enables the given virtual host in `/etc/apache2/sites-available` and disables all other vhosts:

    site makandra-com

Also see http://makandra.com/notes/807-shell-script-to-quickly-switch-apache-sites
