Given(/the docker command cannot find the "(.*?)" binary/) do |command|
  require 'geordi/docker'
  expect_any_instance_of(Geordi::Docker).to receive(:mock_run).at_least(:once).and_wrap_original do |original, *args|
    if args[0] =~ /which #{Regexp.escape(command)}/
      false
    else
      original.call(*args)
    end
  end
end
