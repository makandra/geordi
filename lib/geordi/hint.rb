# Use the methods in this file to hint at other geordi features
require File.expand_path('settings', __dir__)

module Geordi
  class Hint
    class << self

      def did_you_know(hints)
        settings_probability =  Settings.new.hint_probability
        default_probability = (Util.testing? ? 0 : 10) # Percent
        should_print_hint = Random.new.rand(100) <= (settings_probability || default_probability)

        generated_hints = hints.map(&method(:generate))
        if generated_hints.any? && should_print_hint
          puts generated_hints.sample
          puts 'You can configure the probability for these hints by setting hint_probability to a unitless percent number in ~/.config/geordi/global.yml' unless settings_probability
        end

        generated_hints
      end

      private

      def generate(hint)
        if hint.is_a?(Symbol)
          command = Geordi::CLI.commands[hint.to_s]
          description = downcase_first_letter(command.description)
          "Did you know? `geordi #{command.name}` can #{description}"
        elsif hint.is_a?(Array)
          command = Geordi::CLI.commands[hint[0].to_s]
          option = command.options[hint[1]]
          banner = option.banner.nil? ? '' : " #{option.banner}"
          description = downcase_first_letter(option.description)
          "Did you know? `geordi #{command.name} #{option.aliases.first}#{banner}` can #{description}"
        elsif hint.is_a?(String)
          "Did you know? #{hint}"
        else
          raise "Unsupported hint input #{hint.inspect}"
        end
      end

      def downcase_first_letter(str)
        str[0].downcase + str[1..-1]
      end
    end
  end
end
