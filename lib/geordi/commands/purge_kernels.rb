desc 'purge-kernels', 'Purge linux kernels older than the current one'
long_desc <<-LONGDESC
Example: `sudo geordi purge-kernels`

/boot quickly gets cluttered with unused old kernels, finally rendering your
machine unable to install updates.

This script will retrieve and print a list of all current or older kernels. If
confirmed, it will then purge all kernels older than the current one.
LONGDESC

def purge_kernels
  kernels = Util.retrieve_kernels

  announce 'Purging old kernels'
  Util.root_required
  note 'Current kernel: ' + kernels[:current]

  if kernels[:old].any?
    note ['Old kernels:', *kernels[:old].reverse].join "\n"

    Util.system! 'apt-get purge -y ' + kernels[:old].join(' '),
      :show_cmd => true,
      :confirm => true,
      :fail_message => 'Failed, or cancelled.'
  else
    success 'No old kernels found.'
  end
end
