def announce(text)
  message = "\n# #{text}"
  puts "\e[4;34m#{message}\e[0m" # blue underline
end

def note(text)
  puts '> ' + text
end

def fail(text = 'Something went wrong')
  message = "\n#{text}"
  puts "\e[31m#{message}\e[0m" # red
  exit(1)
end

def success(text)
  message = "\n#{text}"
  puts "\e[32m#{message}\e[0m" # green
end
