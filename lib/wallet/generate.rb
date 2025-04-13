# frozen_string_literal: true

module Wallet
  class Generate < Base
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

        KeyStorage.save_key(address:, private_key:)

        address
      end

      def build_message(address)
        "Generated new key:\nAddress: #{address}\nPrivate key saved to: key/#{address}.key"
      end
    end
  end
end
