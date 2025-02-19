# frozen_string_literal: true

RSpec.describe Wallet::TransactionService do # rubocop:disable Metrics/BlockLength
  let(:address) { 'tb1qexampleaddress' }
  let(:private_key) { 'cVexampleprivatekey' }
  let(:credentials) { { address: address, private_key: private_key } }
  let(:to_address) { 'tb1qrecipientaddress' }
  let(:utxos) { [{ 'txid' => 'abcd1234', 'vout' => 0, 'value' => 150_000 }] }
  let(:raw_tx_hex) { '0200000001abcd...' }
  let(:key_mock) { instance_double(Bitcoin::Key, sign: 'signed_data', addr: address) }
  let(:tx_mock) { instance_double(Bitcoin::Protocol::Tx, to_payload: 'tx_payload') }

  before do
    allow(Bitcoin::Key).to receive(:from_base58).with(private_key).and_return(key_mock)
    allow(described_class).to receive(:build_tx).and_return(tx_mock)
    allow(described_class).to receive(:calculate_vsize).and_return(250)
    allow(described_class).to receive(:calculate_fee).and_return(500)
    allow(described_class).to receive(:broadcast_transaction).and_return(true)

    allow(Wallet::WalletStorage).to receive(:load_address).and_return(address)
    allow(Wallet::WalletStorage).to receive(:load_private_key).and_return(private_key)
    allow(Wallet::BalanceChecker).to receive(:check).and_return(200_000)

    allow(ApiConfig.api_service).to receive(:get_address_utxos).and_return(utxos)
    allow(ApiConfig.api_service).to receive(:get_transaction_raw).with('abcd1234').and_return(raw_tx_hex)
    allow(Bitcoin::Protocol::Tx).to receive(:new).and_return(tx_mock)
    allow(ApiConfig.api_service).to receive(:broadcast_transaction).and_return('txid12345')
  end

  describe '#send_bitcoin' do
    context 'when amount is too small' do
      before do
        allow(Wallet::BalanceChecker).to receive(:check).and_return(2_000_000)
      end

      it 'returns an error message' do
        expect { described_class.send_bitcoin(amount: '0.0000005', to: to_address) }
          .to output(/Error: Amount is too small/).to_stdout
      end
    end

    context 'when transaction is created successfully' do
      before do
        allow(Wallet::BalanceChecker).to receive(:check).and_return(2_000_000)
      end

      it 'broadcasts the transaction' do
        expect(described_class.send_bitcoin(amount: '0.001', to: to_address)).to be true
      end
    end
  end
end
