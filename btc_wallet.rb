# frozen_string_literal: true

require 'bundler/setup'
require 'bigdecimal'
require 'bitcoin'
require 'json'
require 'fileutils'
require 'net/http'

require_relative 'config/zeitwerk_config'
ZeitwerkConfig.setup

Bitcoin.network = :testnet3

class CLI
  def self.start
    command = ARGV[0]
    case command
    when 'generate'
      Wallet::Command.execute('generate')
    when 'balance'
      Wallet::Command.execute('balance')
    when 'send'
      amount = ARGV[1]
      to = ARGV[2]
      Wallet::Command.execute('send', amount: amount, to: to)
    else
      show_help
    end
  rescue ArgumentError => e
    puts "Error: #{e.message}"
    show_help
    exit 1
  end

  def self.show_help
    puts <<~HELP
      Usage:
        #{$PROGRAM_NAME} generate
        #{$PROGRAM_NAME} balance
        #{$PROGRAM_NAME} send <amount> <to_address>
    HELP
  end
end

CLI.start
