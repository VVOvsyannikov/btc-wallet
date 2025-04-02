# frozen_string_literal: true

require 'bundler/setup'
require 'bigdecimal'
require 'bitcoin'
require 'json'
require 'fileutils'
require 'net/http'
require 'optparse'
require 'ostruct'
require 'stringio'

require_relative 'config/zeitwerk_config'

class CLI
  class << self
    def call
      setup
      result = ArgumentParser.call
      return print_errors(result.errors) if result.failure?

      execute_command(result.value)
    end

    private

    def setup
      ZeitwerkConfig.setup
      Bitcoin.network = :testnet3
    end

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
