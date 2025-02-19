# frozen_string_literal: true

module Wallet
  class Command
    class << self
      def execute(command, options = {})
        case command
        when 'generate'
          generate_key
        when 'balance'
          check_balance
        when 'send'
          send_transaction(options)
        else
          raise ArgumentError, "Unknown command: #{command}"
        end
      end

      private

      def generate_key
        KeyGenerator.generate
      end

      def check_balance
        BalanceChecker.check
      end

      def send_transaction(options)
        validate_send_params!(options)
        TransactionService.send_bitcoin(
          amount: options[:amount],
          to: options[:to]
        )
      end

      def validate_send_params!(options)
        amount = options[:amount]
        to = options[:to]

        raise ArgumentError, 'Amount is required' if amount.nil?
        raise ArgumentError, "Invalid amount" unless amount.to_s.match?(/\A\d+(\.\d+)?\z/)
        raise ArgumentError, 'Amount must be greater than 0' if amount.to_f <= 0
        raise ArgumentError, 'Recipient address is required' if to.nil? || to.empty?
      end
    end
  end
end
