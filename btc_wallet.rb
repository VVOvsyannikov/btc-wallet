# frozen_string_literal: true

require_relative 'config/initializer'

class CLI
  class << self
    def call
      result = ArgumentParser.call
      return print_errors(result.errors) if result.failure?

      execute_command(result.value)
    end

    private

    def print_errors(errors)
      ConsoleOutput.print_errors(errors)
    end

    def print_result(message)
      ConsoleOutput.print(message)
    end

    def execute_command(options)
      result = Wallet.const_get(options.command.capitalize).call(options)

      result.success? ? print_result(result.message) : print_errors(result.errors)
    end
  end
end

CLI.call
