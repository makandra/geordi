desc 'cucumber [FILES]', 'Run Cucumber features'
long_desc <<-LONGDESC
Example: `geordi cucumber features/authentication_feature:3`

Runs Cucumber as you want: with `bundle exec`, `cucumber_spinner` detection,
separate Firefox for Selenium, etc.

Sometimes, the dot-printing Cucumber formatter does not show errors. In case a
feature fails without a message, try calling with `--debug` or `-d`.

Any unknown option will be passed through to Cucumber, e.g. `--format pretty`.
LONGDESC

option :verbose, :aliases => '-v', :type => :boolean,
  :desc => 'Print the testrun command'
option :debug, :aliases => '-d', :type => :boolean,
  :desc => 'Run with `-f pretty -b` which helps hunting down bugs'
option :rerun, :aliases => '-r', :type => :numeric, :default => 0,
  :desc => 'Rerun features up to N times while failing'

def cucumber(*files)
  if File.directory?('features')
    require 'geordi/cucumber'

    invoke_cmd 'bundle_install'

    announce 'Running features'
    files << '--format' << 'pretty' << '-b' if options.debug
    (1 + options.rerun).times do |i|
      return true if Geordi::Cucumber.new.run(files, :verbose => options.verbose)

      announce "Rerun ##{ i + 1 } of #{ options.rerun }"
    end
    fail 'Features failed.' # Give up

  else
    note 'Cucumber not employed.'
  end
end
