# frozen_string_literal: true

module Wallet
  class Balance < Base
    class << self
      def call(options)
        address = options.from
        utxos = get_address_utxos(address)
        balances = calculate_balances(utxos)
        message = build_balance_info(address, balances)

        Result.success(balances[:confirmed], message)
      rescue StandardError
        Result.failure(error_message)
      end

      private

      def get_address_utxos(address)
        ApiConfig.api_service.get_address_utxos(address)
      end

      def calculate_balances(utxos)
        confirmed_balance = 0
        unconfirmed_balance = 0

        utxos.each do |utxo|
          if utxo['status'].fetch('confirmed', true)
            confirmed_balance += utxo['value']
          else
            unconfirmed_balance += utxo['value']
          end
        end

        { confirmed: confirmed_balance, unconfirmed: unconfirmed_balance }
      end

      def build_balance_info(address, balances)
        confirmed_balance = balances[:confirmed].to_f
        unconfirmed_balance = balances[:unconfirmed].to_f
        total_balance = confirmed_balance + unconfirmed_balance

        <<~INFO
          Address: #{address}
          Confirmed Balance: #{confirmed_balance.to_i} satoshis (#{confirmed_balance / 100_000_000} BTC)
          Pending Balance: #{unconfirmed_balance.to_i} satoshis (#{unconfirmed_balance / 100_000_000} BTC)
          Total Balance: #{total_balance.to_i} satoshis (#{total_balance / 100_000_000} BTC)
        INFO
      end
    end
  end
end
