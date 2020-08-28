When /^I wait for (\d+) seconds?$/ do |seconds|
  sleep seconds.to_i
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

After do
  ENV['GEORDI_TESTING_STAGED_CHANGES'] = 'false'
  ENV['GEORDI_TESTING_GIT_USERNAME'] = nil
  ENV['GEORDI_TESTING_GIT_BRANCHES'] = nil
end
