# frozen_string_literal: true

module Wallet
  class WalletStorage
    class << self
      def save_key(address:, private_key:)
        FileUtils.mkdir_p('key')
        filename = key_path(address)
        File.write(filename, private_key)
      end

      def load_address
        key_file = Dir.glob('key/*.key').first
        raise ArgumentError, 'No wallet found. Generate a key first.' if key_file.nil?

        File.basename(key_file, '.key')
      end

      def load_private_key
        key_file = Dir.glob('key/*.key').first
        raise ArgumentError, 'No wallet found. Generate a key first.' if key_file.nil?

        File.read(key_file).strip
      end

      def key_exists?
        Dir.exist?('key') && !Dir.empty?('key')
      end

      private

      def key_path(address)
        "key/#{address}.key"
      end
    end
  end
end
