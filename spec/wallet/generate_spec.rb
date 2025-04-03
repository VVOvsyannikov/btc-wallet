# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Wallet::Generate do
  describe '#call' do
    let(:addr) { 'tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx' }
    let(:priv) { 'test_private_key' }
    let(:bitcoin_key) { instance_double(Bitcoin::Key, addr:, priv:) }
    let(:result) { Result.success(100_000, balance_message) }
    let(:options) { {} }

    before do
      allow(Bitcoin::Key).to receive(:generate).and_return(bitcoin_key)
      allow(Wallet::KeyStorage).to receive(:save_key).and_return(true)
    end

    it 'generates and saves new key' do
      expect(described_class.call(options).value).to eq(addr)
    end

    context 'when KeyStorage raise error' do
      let(:result) { Result.failure(wrong_message) }

      before do
        allow(Wallet::KeyStorage).to receive(:save_key).and_raise(StandardError)
      end

      it 'returns Result.failure' do
        expect(described_class.call(options).errors).to eq(result.errors)
      end
    end
  end
end
