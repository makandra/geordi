require_relative 'lib/geordi/interaction'

require 'bundler'
Bundler::GemHelper.install_tasks

# Run this before releasing
Rake::Task['release:guard_clean'].enhance [:check]

desc 'Default: Run all tests'
task default: [:rspec, :features]

task :features do
  system 'bundle exec cucumber'
end

task :rspec do
  system 'bundle exec rspec'
end

task :check do
  Geordi::Interaction.confirm_or_cancel('Are all specs & features green?', 'Please run all tests with `rake`.', default: 'n')
  Geordi::Interaction.confirm_or_cancel('Have you updated the README?', 'Please update the README with `rake readme`.', default: 'n')
  Geordi::Interaction.confirm_or_cancel('Have you updated the CHANGELOG?', 'Please update the CHANGELOG with the latest changes.', default: 'n')
end

task :readme do
  require File.expand_path('lib/geordi/cli', __dir__)

  readme = File.read('README.md')
  geordi_section_regex = /
    `geordi`\n
    -{3,}   # 3 dashes or more
    .*?     # anything, non-greedy
    (?=     # stop before:
      ^\w+\n-{3,} # the next section
    )
  /xm

  geordi_section = <<-TEXT
`geordi`
--------

The `geordi` binary holds most of the utility commands. For the few other
binaries, see the bottom of this file.

You may abbreviate commands by typing only their first letters, e.g. `geordi
con` will boot a development console, `geordi set -t` will setup a project and
run tests afterwards.

Commands will occasionally print "did you know" hints of other Geordi features.

You can always run `geordi help <command>` to quickly look up command help.
  TEXT

  Geordi::CLI.all_commands.sort.each do |_, command|
    next if command.hidden?

    geordi_section << "\n### `geordi #{command.usage}`\n"
    geordi_section << "#{command.description.sub /(\.)?$/, '.'}\n\n"
    geordi_section << "#{command.long_description.strip}\n\n" if command.long_description

    visible_options = command.options.reject {|_option_name, option_object| option_object.hide }

    if visible_options.any?
      geordi_section << "**Options**\n"
      visible_options.values.each do |option|
        usage = option.usage
          .gsub(/\[(--.*?)\]/, '\1')
          .sub(/, --no-[\w-]+, --skip-[\w-]+$/, '')

        geordi_section << "- `#{usage}`"
        geordi_section << ": #{option.description}" if option.description
        geordi_section << "\n"
      end
      geordi_section << "\n"
    end
  end

  updated_readme = readme.sub(geordi_section_regex, geordi_section)
  File.open('README.md', 'w') { |f| f.puts updated_readme.strip }
  puts 'README.md updated.'
end
