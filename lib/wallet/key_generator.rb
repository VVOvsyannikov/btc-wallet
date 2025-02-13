# frozen_string_literal: true

module Wallet
  class KeyGenerator
    class << self
      def generate
        check_existing_key
        create_and_save_key
      end

      private

      def check_existing_key
        return unless WalletStorage.key_exists?

        puts 'Key already exists in key/ directory'
        exit
      end

      def create_and_save_key
        key = Bitcoin::Key.generate
        address = key.addr

        WalletStorage.save_key(
          address: address,
          private_key: key.priv
        )

        display_key_info(address)
      end

      def display_key_info(address)
        puts 'Generated new key:'
        puts "Address: #{address}"
        puts "Private key saved to: key/#{address}.key"
      end
    end
  end
end
