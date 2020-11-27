When /^I wait for (\d+) seconds?$/ do |seconds|
  sleep seconds.to_i
end

Given 'I have staged changes' do
  ENV['GEORDI_TESTING_STAGED_CHANGES'] = 'true'
end

After do
  ENV['GEORDI_TESTING_STAGED_CHANGES'] = 'false'
end
