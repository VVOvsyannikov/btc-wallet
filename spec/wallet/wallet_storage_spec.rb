# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Wallet::WalletStorage do # rubocop:disable Metrics/BlockLength
  describe '#load_address' do
    let(:test_address) { 'tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx' }

    before do
      allow(Dir).to receive(:glob).and_return(["key/#{test_address}.key"])
    end

    it 'returns address' do
      expect(described_class.load_address).to eq(test_address)
    end

    context 'when no key exists' do
      before do
        allow(Dir).to receive(:glob).and_return([])
      end

      it 'raises error' do
        expect { described_class.load_address }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#save_key' do
    let(:test_address) { 'tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx' }
    let(:test_private_key) { 'test_private_key' }

    before do
      allow(FileUtils).to receive(:mkdir_p)
      allow(File).to receive(:write)
    end

    it 'creates key directory' do
      expect(FileUtils).to receive(:mkdir_p).with('key')
      described_class.save_key(address: test_address, private_key: test_private_key)
    end

    it 'saves private key to file' do
      expect(File).to receive(:write).with("key/#{test_address}.key", test_private_key)
      described_class.save_key(address: test_address, private_key: test_private_key)
    end
  end
end
