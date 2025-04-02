# frozen_string_literal: true

module Wallet
  class Generate
    class << self
      def call(_options)
        key_address = create_key
        Result.success(key_address, build_message(key_address))
      rescue StandardError
        Result.failure(error_message)
      end

      private

      def create_key
        key = Bitcoin::Key.generate
        address = key.addr
        private_key = key.priv

        WalletStorage.save_key(address:, private_key:)

        address
      end

      def build_message(address)
        "Generated new key:\nAddress: #{address}\nPrivate key saved to: key/#{address}.key"
      end

      def error_message
        ['Something went wrong, please, try later']
      end
    end
  end
end
