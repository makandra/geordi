require 'ripper'

module Geordi
  class CapistranoConfigParser < Ripper
    def self.parse(*args)
      raise 'invalid deployment configuration' unless sexp(*args)

      super(*args)
    end

    def initialize(*)
      super
      @data = { rails_env: [], server: {}, user: [] }
    end

    def parse(*)
      super
      @data
    end

    def on_args(args, arg)
      args << arg
    end

    def on_args_add(args, arg)
      args << arg
      args
    end

    def on_args_add_block(args, arg)
      args
    end

    def on_args_new
      []
    end

    def on_arg_paren(*args)
      args[0]
    end

    def on_array(*args)
      args[0]
    end

    def on_assoc_new(key, value)
      [key, value[0]]
    end

    def on_bare_assoc_hash(value)
      Hash[value]
    end

    def on_command(cmd, args)
      add_server(args) if cmd == 'server'
      add_rails_env(args) if cmd == 'set' && args[0] == 'rails_env'
      add_user(args) if cmd == 'set' && args[0] == 'user'
    end

    def on_fcall(*args)
      args[0]
    end

    def on_method_add_arg(mname, args)
      add_server(args) if mname == 'server'
      add_rails_env(args) if mname == 'set' && args[0] == 'rails_env'
      add_user(args) if mname == 'set' && args[0] == 'user'
      args
    end

    def on_program(stmts) 
      stmts
    end

    def on_qwords_add(qwords, qword)
      qwords << qword[0]
      qwords
    end

    def on_qwords_new(*args)
      []
    end

    def on_stmts_add(stmts, stmt) 
      stmts << stmt
    end

    def on_stmts_new
      []
    end

    def on_string_add(str, newstr)
      fullnewstr = newstr.concat
      return fullnewstr if str.nil?

      str + fullnewstr
    end

    def on_string_literal(value)
      value
    end

    def on_tstring_content(*args)
      args
    end

    private

    def add_rails_env(args)
      @data[:rails_env] << args[1][0]
    end

    def add_server(args)
      @data[:server][args[0][0]] = { user: args[1]['user:'] }
    end

    def add_user(args)
      @data[:user] << args[1][0]
    end
  end
end
