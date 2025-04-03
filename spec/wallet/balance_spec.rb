# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Wallet::Balance do
  describe '#call' do
    let(:api_service) { class_double(ApiServices::Mempool) }
    let(:from) { 'tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx' }
    let(:command_options) { Struct.new(:command, :amount, :from, :to) }
    let(:options) { command_options.new(command: 'balance', from:) }
    let(:result) { Result.success(100_000, balance_message) }

    before do
      allow(Wallet::KeyStorage).to receive(:check_address).with(from).and_return(true)
      allow(ApiConfig).to receive(:api_service).and_return(api_service)
      allow(api_service).to receive(:get_address_utxos).with(from).and_return(utxos)
    end

    it 'returns correct value' do
      expect(described_class.call(options).value).to eq(result.value)
    end

    it 'returns correct message' do
      expect(described_class.call(options).message).to eq(result.message)
    end

    context 'when api service raise error' do
      let(:result) { Result.failure(wrong_message) }

      before do
        allow(ApiConfig).to receive(:api_service).and_raise(StandardError)
      end

      it 'returns Result.failure' do
        expect(described_class.call(options).errors).to eq(result.errors)
      end
    end
  end
end
