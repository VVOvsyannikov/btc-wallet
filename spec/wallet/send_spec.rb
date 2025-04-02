# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Wallet::Send do
  let(:api_service) { class_double(ApiServices::Mempool) }
  let(:balance) { Struct.new(:value).new(value: 100_000) }
  let(:options) do
    Struct.new(:command, :amount, :from, :to).new(
      command: 'send',
      amount: '0.0000075',
      from: 'mfrBqTAYAAUQJZJZk7EDH7eRyDjwHfr1wn',
      to: 'tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx'
    )
  end

  before do
    private_key = 'some_private_key'
    key_mock = instance_double(Bitcoin::Key, sign: 'signed_data', addr: options.from)
    tx_mock = instance_double(Bitcoin::Protocol::Tx, to_payload: 'tx_payload')
    raw_tx_hex = '0200000001abcd...'
    allow(ApiConfig).to receive(:api_service).and_return(api_service)
    allow(Wallet::Balance).to receive(:call).and_return(balance)
    allow(Wallet::WalletStorage).to receive(:load_private_key).and_return(private_key)
    allow(Bitcoin::Key).to receive(:from_base58).with(private_key).and_return(key_mock)
    allow(Bitcoin::Protocol::Tx).to receive(:new).and_return(tx_mock)
    allow(api_service).to receive(:get_address_utxos).with(options.from).and_return(utxos)
    allow(api_service).to receive(:get_transaction_raw).and_return(raw_tx_hex)
    allow(described_class).to receive_messages(
      broadcast_transaction: 'some_tx_id',
      build_tx: tx_mock,
      calculate_vsize: 250
    )
  end

  describe '#call' do
    context 'when transaction is created successfully' do
      let(:result) { Result.success('some_tx_id', response) }

      it 'broadcasts the transaction' do
        expect(described_class.call(options).message).to eq(result.message)
      end
    end

    context 'when amount is too small' do
      before do
        options.amount = '0.0000005'
      end

      it 'returns an error message' do
        expect(described_class.call(options).errors).to include('Amount must be bigger than 0 BTC')
      end
    end

    context 'when insufficient funds' do
      let(:balance) { Struct.new(:value).new(value: 0) }

      it 'returns an error message' do
        expect(described_class.call(options).errors).to include(
          'Insufficient funds. Current balance: 0 satoshis, amount: 750 satoshis'
        )
      end
    end

    context 'when some service raise error' do
      let(:result) { Result.failure(wrong_message) }

      before do
        allow(described_class).to receive(:make_transaction).and_raise(StandardError)
      end

      it 'returns Result.failure' do
        expect(described_class.call(options).errors).to eq(result.errors)
      end
    end
  end
end
