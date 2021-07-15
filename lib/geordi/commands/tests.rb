desc 'tests [FILES]', 'Run all employed tests'
long_desc <<-LONGDESC
When running `geordi tests` without any arguments, all unit tests, rspec specs
and cucumber features will be run.

When passing arguments, Geordi will forward them to either `rspec` or `cucumber`,
depending on what the first argument indicates.
LONGDESC

def tests(*args)
  if args.any?
    args, opts = Thor::Options.split(args)
    error_message = "When passing arguments, the first argument must be either an RSpec or a Cucumber path."

    if args.empty?
      Interaction.fail error_message
    elsif args.first.start_with? 'spec'
      invoke 'rspec', args, opts
    elsif args.first.start_with? 'features'
      invoke 'cucumber', args, opts
    else
      Interaction.fail error_message
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
end
