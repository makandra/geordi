Given(/^(?:a|the) file(?: named)? "([^"]*)" with "([^"]*)"$/) do |file_name, file_content|
  unescape_content = file_content.gsub('\n', "\n").gsub('\"', '"').gsub('\e', "\e").gsub('\033', "\e").gsub('\016', "\016").gsub('\017', "\017").gsub('\t', "\t")

  write_file(file_name, unescape_content)
end
