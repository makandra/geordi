desc 'cucumber [FILES and OPTIONS]', 'Run Cucumber features'
long_desc <<-LONGDESC
Example: `geordi cucumber features/authentication_feature:3`

Runs Cucumber with `bundle exec`, using parallel tests, with a VNC session
holding Selenium test browsers, support for using a dedicated testing browser
and beta support for re-running failed scenarios.

- *@solo:* Generally, features are run in parallel. However, scenarios tagged
with @solo are excluded from the parallel run and executed sequentially instead.

- *Debugging:* In some cases, the dot-printing Cucumber formatter swallows
errors. In case a feature fails without an error message, try running it with
`--debug` or `-d`.

- *Options:* Any unknown option will be passed through to Cucumber,
e.g. `--format=pretty`. Make sure to connect option and value with an equals
sign, i.e. have each option a contiguous string.

- *VNC:* By default, test browsers will run in a VNC session. When using a
headless test browser anyway, you can disable VNC by setting `use_vnc: false`
in `.geordi.yml` in the project root.
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

    invoke_geordi 'bundle_install'
    invoke_geordi 'yarn_install'
    invoke_geordi 'chromedriver_update', quiet_if_matching: true

    cmd_opts, files = args.partition { |f| f.start_with? '-' }
    cmd_opts << '--format' << 'pretty' << '--backtrace' if options.debug

    # Serial run of @solo scenarios ############################################
    if files.any? { |f| f.include? ':' }
      Interaction.note '@solo run skipped when called with line numbers' if options.verbose
    else
      solo_files = if files.empty?
        'features' # Proper grepping
      else
        files.join(' ')
      end

      solo_tag_usages = `grep -r '@solo' #{solo_files}`.split("\n")

      if solo_tag_usages.any?
        solo_cmd_opts = cmd_opts.dup
        solo_cmd_opts << '--tags' << '@solo'

        Interaction.announce 'Running @solo features'
        solo_success = Geordi::Cucumber.new.run files, solo_cmd_opts, verbose: options.verbose, parallel: false
        solo_success || Interaction.fail('Features failed.')
      end
    end

    # Parallel run of all given features + reruns ##############################
    Interaction.announce 'Running features'
    normal_run_successful = Geordi::Cucumber.new.run(files, cmd_opts, verbose: options.verbose)

    unless normal_run_successful
      cmd_opts << '--profile' << 'rerun'

      # Reruns
      (options.rerun + 1).times do |i|
        Interaction.fail 'Features failed.' if i == options.rerun # All reruns done?

        Interaction.announce "Rerun ##{i + 1} of #{options.rerun}"
        break if Geordi::Cucumber.new.run([], cmd_opts, verbose: options.verbose, parallel: false)
      end
    end

    Interaction.success 'Features green.'

  else
    Interaction.note 'Cucumber not employed.'
  end
end
