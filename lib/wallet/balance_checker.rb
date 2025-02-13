# frozen_string_literal: true

module Wallet
  class BalanceChecker
    class << self
      def check
        address = load_address
        utxos = get_address_utxos(address)
        balances = calculate_balances(utxos)
        print_balance_info(address, balances)

        balances[:confirmed]
      end

      private

      def load_address
        WalletStorage.load_address
      end

      def get_address_utxos(address)
        ApiConfig.api_service.get_address_utxos(address)
      end

      def calculate_balances(utxos)
        confirmed_balance = 0
        unconfirmed_balance = 0

        utxos.each do |utxo|
          if utxo['status']&.fetch('confirmed', true)
            confirmed_balance += utxo['value']
          else
            unconfirmed_balance += utxo['value']
          end
        end

        { confirmed: confirmed_balance, unconfirmed: unconfirmed_balance }
      end

      def print_balance_info(address, balances) # rubocop:disable Metrics/AbcSize
        puts "Address: #{address}"
        puts "Confirmed Balance: #{balances[:confirmed]} satoshis (#{balances[:confirmed].to_f / 100_000_000} BTC)"
        puts "Pending Balance: #{balances[:unconfirmed]} satoshis (#{balances[:unconfirmed].to_f / 100_000_000} BTC)"
        puts "Total Balance: #{balances[:confirmed] + balances[:unconfirmed]} satoshis (#{(balances[:confirmed] +
          balances[:unconfirmed]).to_f / 100_000_000} BTC)"
      end
    end
  end
end
