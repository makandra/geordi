desc 'tests [FILES and OPTIONS]', 'Run all employed tests'
long_desc <<-LONGDESC
When running `geordi tests` without any arguments, all unit tests, rspec specs
and cucumber features will be run.

When running `geordi tests` with arguments, it will invoke either
`geordi rspec` or `geordi cucumber` to run the test, depending on whether the
path in the first argument starts with "spec" or "features".

Command line arguments are passed to `geordi rspec`/`geordi cucumber` as well.
LONGDESC

def tests(*args)
  if args.any?
    args, opts = Thor::Options.split(args)

    if args.empty?
      Interaction.fail "geordi tests only supports arguments if one or more test files/directories are specified."
    elsif args.first.start_with? 'spec'
      invoke 'rspec', args, opts
    elsif args.first.start_with? 'features'
      invoke 'cucumber', args, opts
    else
      Interaction.fail "geordi tests cannot process the argument #{args.first}. The first argument has to be a path beginning with \"spec\" or \"features\"."
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
