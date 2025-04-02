# frozen_string_literal: true

class ArgumentParser
  CommandOptions = Struct.new(:command, :amount, :from, :to)

  class << self
    def call
      options = parse_options(CommandOptions.new)
      errors = validate_options(options)

      errors.empty? ? Result.success(options, nil) : Result.failure(errors)
    end

    private

    def parse_options(options)
      OptionParser.new { |opts| define_options(opts, options) }.parse!
      options
    end

    def define_options(opts, options)
      opts.on('-g') { options.command = 'generate' }
      opts.on('-b') { options.command = 'balance' }
      opts.on('-s') { options.command = 'send' }
      opts.on('-a [AMOUNT]') { |amount| options.amount = amount }
      opts.on('-f [ADDRESS]') { |from| options.from = from }
      opts.on('-t [ADDRESS]') { |to| options.to = to }
    end

    def validate_options(options)
      send("validate_#{options.command}_options", options)
    end

    def validate_generate_options(options)
      errors = []
      errors << 'Command generate do not allow any arguments' if options.amount || options.from || options.to
      errors
    end

    def validate_balance_options(options)
      errors = []
      errors << 'Command balance do not allow argument amount=<amount>' if options.amount
      errors << 'Command balance do not allow argument to=<address>' if options.to
      errors << 'Required from=<address> (wallet address) argument' unless options.from
      errors << 'Invalid from=<address> argument' unless Bitcoin.valid_address?(options.from)
      errors
    end

    def validate_send_options(options)
      [
        validate_presence(options),
        validate_amount(options.amount),
        validate_addresses(options.from, options.to)
      ].flatten.compact
    end

    def validate_presence(options)
      errors = []
      errors << 'Required amount=<amount> argument' unless options.amount
      errors << 'Required from=<address> argument' unless options.from
      errors << 'Required to=<address> argument' unless options.to
      errors
    end

    def validate_amount(amount)
      errors = []
      errors << 'Amount must be a number in BTC (not Satoshis)' unless amount.to_s.match?(/\A\d+(\.\d+)?\z/)
      errors << 'Amount must be greater than 0' if amount.to_f <= 0
      errors
    end

    def validate_addresses(from, to)
      errors = []
      errors << 'Invalid from=<address> argument' unless Bitcoin.valid_address?(from)
      errors << 'Invalid to=<address> argument' unless Bitcoin.valid_address?(to)
      errors
    end
  end
end
