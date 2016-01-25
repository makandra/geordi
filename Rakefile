require 'bundler'
Bundler::GemHelper.install_tasks

desc 'Default: Run all tests'
task :default => :features

task :features do
  system 'cucumber'
end

task :update_readme do
  require File.expand_path('../lib/geordi/cli', __FILE__)

  readme = File.read('README.md')
  geordi_section_regex = /
    geordi\n
    -{3,}   # 3 dashes or more
    .*?     # anything, non-greedy
    (?=     # stop before:
      ^\w+\n-{3,} # the next section
    )
  /xm

  geordi_section = <<-TEXT
geordi
------

The base command line utility offering most of the commands.

You may abbreviate commands by typing only the first letter(s), e.g. `geordi
dev` will boot a development server, `geordi s -t` will setup a project and run
tests afterwards. Underscores and dashes are equivalent.

For details on commands, e.g. supported options, run `geordi help <command>`.

  TEXT

  Geordi::CLI.all_commands.sort.each do |_, command|
    unless command.hidden?
      geordi_section << "### geordi #{ command.usage }\n\n"
      geordi_section << "#{ command.description.sub /(\.)?$/, '.' }\n\n"
      geordi_section << "#{ command.long_description.strip }\n\n" if command.long_description
      geordi_section << "\n"
    end
  end

  updated_readme = readme.sub(geordi_section_regex, geordi_section)
  File.open('README.md', 'w') { |f| f.puts updated_readme.strip }
end
