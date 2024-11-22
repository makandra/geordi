When /^I wait for (\d+) seconds?$/ do |seconds|
  sleep seconds.to_i
end

Given /^the irb version is "(.*)"$/ do |version|
  ENV['GEORDI_TESTING_IRB_VERSION'] = version
end

Given /^the Ruby version is "(.*)"/ do |version|
  ENV['GEORDI_TESTING_RUBY_VERSION'] = version
end

Given 'I have staged changes' do
  ENV['GEORDI_TESTING_STAGED_CHANGES'] = 'true'
end

Given /^my local git branches are: (.*)$/ do |branches|
  ENV['GEORDI_TESTING_GIT_BRANCHES'] = branches.split(", ").join("\n") + "\n"
end

Given /^my default branch is "(.*)"$/ do |default_branch|
  ENV['GEORDI_TESTING_DEFAULT_BRANCH'] = default_branch
end

Given 'there are no Linear issues' do
  ENV['GEORDI_TESTING_NO_LINEAR_ISSUES'] = 'true'
end

After do
  ENV['GEORDI_TESTING_STAGED_CHANGES'] = 'false'
  ENV['GEORDI_TESTING_GIT_BRANCHES'] = nil
  ENV['GEORDI_TESTING_NO_LINEAR_ISSUES'] = nil
  ENV['GEORDI_TESTING_IRB_VERSION'] = nil
  ENV['GEORDI_TESTING_RUBY_VERSION'] = nil
  ENV['GEORDI_TESTING_DEFAULT_BRANCH'] = nil
end
