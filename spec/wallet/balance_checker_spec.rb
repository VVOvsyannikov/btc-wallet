# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Wallet::BalanceChecker do # rubocop:disable Metrics/BlockLength
  describe '#check' do # rubocop:disable Metrics/BlockLength
    let(:test_address) { 'tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx' }
    let(:api_service) { class_double(ApiServices::Mempool) }
    let(:utxos) do
      [
        {
          'txid' => '7a6cd8404a8daf0e0e9d32789f30e90fb9845ce56e118ca1df27c0257848d746',
          'vout' => 0,
          'value' => 100_000,
          'status' => {
            'confirmed' => true,
            'block_height' => 235_175,
            'block_hash' => '0000009a63e97ccd43de0e1d9e197bbda1c32c134a85114af86549214bc5dffa',
            'block_time' => 1_739_445_871
          }
        },
        {
          'txid' => '8b7cd8404a8daf0e0e9d32789f30e90fb9845ce56e118ca1df27c0257848d747',
          'vout' => 1,
          'value' => 200_000,
          'status' => {
            'confirmed' => false
          }
        }
      ]
    end

    before do
      allow(Wallet::WalletStorage).to receive(:load_address).and_return(test_address)
      allow(ApiConfig).to receive(:api_service).and_return(api_service)
    end

    it 'returns confirmed balance' do
      allow(api_service).to receive(:get_address_utxos).with(test_address).and_return(utxos)
      expect(described_class.check).to eq(100_000)
    end

    it 'returns unconfirmed balance' do
      allow(api_service).to receive(:get_address_utxos).with(test_address).and_return(utxos)
      expect(described_class.check).not_to eq(200_000)
    end

    it 'prints balance information' do
      allow(api_service).to receive(:get_address_utxos).with(test_address).and_return(utxos)
      expect { described_class.check }.to output(
        "Address: #{test_address}\n" \
        "Confirmed Balance: 100000 satoshis (0.001 BTC)\n" \
        "Pending Balance: 200000 satoshis (0.002 BTC)\n" \
        "Total Balance: 300000 satoshis (0.003 BTC)\n"
      ).to_stdout
    end
  end
end
