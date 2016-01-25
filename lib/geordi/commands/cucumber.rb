desc 'cucumber [FILES]', 'Run Cucumber features'
long_desc <<-LONGDESC
Example: `geordi cucumber features/authentication_feature:3`

Runs Cucumber as you want: with `bundle exec`, using parallel tests, with
a VNC session holding Selenium test browsers, support for using a dedicated
testing firefox and beta support for rerunning failed scenarios.

- *@solo:* Generally, features are run in parallel. However, scenarios tagged
with @solo are excluded and will be run sequentially, _after_ the parallel run.

- *Debugging:* Sometimes, the dot-printing Cucumber formatter does not show
errors. In case a feature fails without a message, try running it with `--debug`
or `-d`.

- *Options:* Any unknown option will be passed through to Cucumber,
e.g. `--format pretty`.
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
    files << '--format' << 'pretty' << '--backtrace' if options.debug

    # Normal run
    unless Geordi::Cucumber.new.run(files, :verbose => options.verbose)

      # Reruns
      (1 + options.rerun).times do |i|
        fail 'Features failed.' if (i == options.rerun) # All reruns done?

        announce "Rerun ##{ i + 1 } of #{ options.rerun }"
        break if Geordi::Cucumber.new.run(%w[--profile rerun], :verbose => options.verbose, :parallel => false)
      end
    end

    # Serial run of @solo scenarios
    solo_tag_usages = `grep -r '@solo' features`.split("\n")
    if solo_tag_usages.any?
      announce 'Running @solo features'
      Geordi::Cucumber.new.run %w[--tags @solo], :verbose => options.verbose, :parallel => false
    end

  else
    note 'Cucumber not employed.'
  end
end
