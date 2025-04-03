# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Wallet::KeyStorage do
  let(:address) { 'test_address' }
  let(:private_key) { 'test_private_key' }
  let(:key_path) { "key/#{address}.key" }

  after do
    FileUtils.rm_rf("key/#{address}.key")
  end

  describe '#save_key' do
    it 'create *.key file' do
      described_class.save_key(address:, private_key:)

      expect(File.exist?(key_path)).to be true
    end

    it 'saves the private key to a file' do
      described_class.save_key(address:, private_key:)

      expect(File.read(key_path).strip).to eq(private_key)
    end
  end

  describe '#check_address' do
    it 'returns true if the address exists' do
      File.write(key_path, private_key)

      expect(described_class.check_address(address)).to be true
    end

    it 'returns false if the address does not exist' do
      expect(described_class.check_address(address)).to be false
    end
  end

  describe '#load_private_key' do
    it 'loads the private key from the file' do
      File.write(key_path, private_key)

      expect(described_class.load_private_key(address)).to eq(private_key)
    end
  end
end
