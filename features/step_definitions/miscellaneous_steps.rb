When /^I wait for (\d+) seconds?$/ do |seconds|
  sleep seconds.to_i
end

Given /^the irb version is "(.*)"$/ do |version|
  ENV['GEORDI_TESTING_IRB_VERSION'] = version
end

Given 'I have staged changes' do
  ENV['GEORDI_TESTING_STAGED_CHANGES'] = 'true'
end

Given /^my username from git config is "(.*)"$/ do |username|
  ENV['GEORDI_TESTING_GIT_USERNAME'] = username
end

Given /^my local git branches are: (.*)$/ do |branches|
  ENV['GEORDI_TESTING_GIT_BRANCHES'] = branches.split(", ").join("\n") + "\n"
end

Given 'there are no stories' do
  ENV['GEORDI_TESTING_NO_PT_STORIES'] = 'true'
end

After do
  ENV['GEORDI_TESTING_STAGED_CHANGES'] = 'false'
  ENV['GEORDI_TESTING_GIT_USERNAME'] = nil
  ENV['GEORDI_TESTING_GIT_BRANCHES'] = nil
  ENV['GEORDI_TESTING_NO_PT_STORIES'] = nil
  ENV['GEORDI_TESTING_IRB_VERSION'] = nil
end
