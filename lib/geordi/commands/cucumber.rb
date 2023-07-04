desc 'cucumber [FILES and OPTIONS]', 'Run Cucumber features'
long_desc <<-LONGDESC
Example: `geordi cucumber features/authentication_feature:3`

Runs Cucumber with `bundle exec`, using parallel tests and with support for
re-running failed scenarios.

Any unknown option will be passed through to Cucumber, e.g. `--format=pretty`.
Make sure to connect option and value with an equals sign, i.e. have each option
a contiguous string.

In order to limit processes in a parallel run, you can set an environment
variable like this: `PARALLEL_TEST_PROCESSORS=6 geordi cucumber`
LONGDESC

option :modified, aliases: '-m', type: :boolean,
  desc: 'Run all modified features'
option :containing, aliases: '-c', banner: 'STRING',
  desc: 'Run all features that contain STRING'
option :verbose, aliases: '-v', type: :boolean,
  desc: 'Show the test run command'
option :debug, aliases: '-d', type: :boolean,
  desc: 'Run Cucumber with `-f pretty -b`, which helps hunting down bugs'
option :rerun, aliases: '-r', type: :numeric, default: 0,
  desc: 'Rerun features up to N times while failing'

def cucumber(*args)
  if args.empty?
    # This is not testable as there is no way to stub `git` :(
    if options.modified?
      modified_features = `git status --short`.split("\n").map do |line|
        indicators = line.slice!(0..2) # Remove leading indicators
        line if line.include?('.feature') && !indicators.include?('D')
      end.compact
      args = modified_features
    end

    if options.containing
      matching_features = `grep -lri '#{options.containing}' --include=*.feature features/`.split("\n")
      args = matching_features.uniq
    end
  end

  if File.directory?('features')
    require 'geordi/cucumber'

    settings = Geordi::Settings.new

    invoke_geordi 'bundle_install'
    invoke_geordi 'yarn_install'
    if settings.auto_update_chromedriver
      invoke_geordi 'chromedriver_update', quiet_if_matching: true
    end

    arguments = args
    arguments << '--format' << 'pretty' << '--backtrace' if options.debug

    # Parallel run of all given features + reruns ##############################
    Interaction.announce 'Running features'
    normal_run_successful = Geordi::Cucumber.new.run(arguments, verbose: options.verbose)

    unless normal_run_successful
      arguments << '--profile' << 'rerun'
      # Reruns
      (options.rerun + 1).times do |i|
        Interaction.fail 'Features failed.' if i == options.rerun # All reruns done?

        Interaction.announce "Rerun ##{i + 1} of #{options.rerun}"
        break if Geordi::Cucumber.new.run(arguments, verbose: options.verbose, parallel: false)
      end
    end

    Interaction.success 'Features green.'

    Hint.did_you_know [
      :rspec,
      [:cucumber, :modified],
      [:cucumber, :containing],
      [:cucumber, :debug],
      'Geordi can automatically update chromedriver before Cucumber tests. See `geordi help chromedriver-update`.'
    ]
  else
    Interaction.note 'Cucumber not employed.'
  end
end
