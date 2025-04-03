# frozen_string_literal: true

module Wallet
  class KeyStorage
    class << self
      def save_key(address:, private_key:)
        FileUtils.mkdir_p('key')
        filename = key_path(address)
        File.write(filename, private_key)
      end

      def check_address(address)
        File.exist?(key_path(address))
      end

      def load_private_key(address)
        File.read(key_path(address)).strip
      end

      private

      def key_path(address)
        "key/#{address}.key"
      end
    end
  end
end
