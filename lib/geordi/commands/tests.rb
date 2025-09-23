desc 'tests [FILES]', 'Run all employed tests'
long_desc <<-LONGDESC
When running `geordi tests` without any arguments, all unit tests, rspec specs
and cucumber features will be run.

When passing file paths or directories as arguments, Geordi will forward them to `rspec` and `cucumber`.
All rspec specs and cucumber features matching the given paths will be run.
LONGDESC

def tests(*args)
  if args.any?
    args, opts = Thor::Options.split(args)
    error_message = "When passing arguments, the first argument must be either an RSpec or a Cucumber path."

    if args.empty?
      Interaction.fail error_message
    else
      rspec_paths = args.select { |a| Util.rspec_path?(a) }
      cucumber_paths = args.select { |a| Util.cucumber_path?(a) }

      invoke('rspec', rspec_paths, opts) if rspec_paths.any?
      invoke('cucumber', cucumber_paths, opts) if cucumber_paths.any?
    end
  else
    rake_result = invoke_geordi 'with_rake'

    # Since `rake` usually is configured to run all tests, only run them if `rake`
    # did not perform
    if rake_result == :did_not_perform
      invoke_geordi 'unit'
      invoke_geordi 'rspec'
      invoke_geordi 'cucumber'
    end

    Interaction.success 'Successfully ran tests.'
  end

  Hint.did_you_know [
    :deploy,
  ]
end
