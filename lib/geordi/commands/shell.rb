# This method has a triple 'l' because :shell is a Thor reserved word. However,
# it can still be called with `geordi shell`.
desc 'shell TARGET', 'Open a shell on a Capistrano deploy target'
def shelll(target, *args)
  GeordiShell.run(target, args)
end

class GeordiShell

  def self.run(target, args)
    require File.expand_path('../../capistrano', __FILE__)
    extend Geordi::Capistrano

    catching_errors do
      self.stage = target
      command = args.any? ? args.join(' ') : nil

      shell_for(command, :select_server => true)
    end
  end

end
