require 'bundler'
Bundler::GemHelper.install_tasks

task :update_readme do
  require File.expand_path('../lib/geordi/cli', __FILE__)

  readme = File.read('README.md')
  geordi_section_regex = /
    geordi\n
    -{3,}   # 3 dashes or more
    .*?     # anything, non-greedy
    (?=     # stop before:
      \n\n\w+\n-{3,} # the next section
    )
  /xm

  geordi_section = <<-TEXT
geordi
------

The base command line utility offering the commands below.

You may abbreviate commands by typing only the first letter(s), e.g. `geordi
dev` will boot a development server, `geordi s -t` will setup a project and run
tests afterwards.

Underscores and dashes are equivalent.

  TEXT

  Geordi::CLI.all_commands.sort.each do |_, command|
    unless command.hidden?
      geordi_section << "### geordi #{command.usage}\n\n"
      geordi_section << "#{command.description}\n\n"
      geordi_section << "#{command.long_description.strip}\n\n" if command.long_description
      geordi_section << "\n"

    end
  end

  updated_readme = readme.sub(geordi_section_regex, geordi_section)
  File.open('README.md', 'w') { |f| f.puts updated_readme.strip }
end
