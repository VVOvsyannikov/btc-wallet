# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Wallet::KeyGenerator do # rubocop:disable Metrics/BlockLength
  describe '#generate' do
    let(:address) { 'test_address' }
    let(:private_key) { 'test_private_key' }
    let(:bitcoin_key) { double('Bitcoin::Key', addr: address, priv: private_key) }

    before do
      allow(Bitcoin::Key).to receive(:generate).and_return(bitcoin_key)
      allow(Wallet::WalletStorage).to receive(:key_exists?).and_return(false)
      allow(Wallet::WalletStorage).to receive(:save_key)
    end

    it 'generates and saves new key' do
      expect(Wallet::WalletStorage).to receive(:save_key).with(
        address: address,
        private_key: private_key
      )
      described_class.generate
    end

    context 'when key already exists' do
      before do
        allow(Wallet::WalletStorage).to receive(:key_exists?).and_return(true)
      end

      it 'does not generate new key' do
        expect(Bitcoin::Key).not_to receive(:generate)
        expect { described_class.generate }.to raise_error(SystemExit)
      end
    end
  end

  describe '#check_existing_key' do # rubocop:disable Metrics/BlockLength
    let(:storage) { Wallet::WalletStorage }
    let(:generator) { described_class }

    context 'when key does not exist' do
      before do
        allow(storage).to receive(:key_exists?).and_return(false)
      end

      it 'returns nil' do
        expect(generator.send(:check_existing_key)).to be_nil
      end

      it 'does not exit the program' do
        expect do
          generator.send(:check_existing_key)
        end.not_to raise_error
      end
    end

    context 'when key exists' do
      before do
        allow(storage).to receive(:key_exists?).and_return(true)
        allow($stdout).to receive(:puts)
      end

      it 'outputs warning message' do
        expect($stdout).to receive(:puts).with('Key already exists in key/ directory')

        expect do
          generator.send(:check_existing_key)
        end.to raise_error(SystemExit)
      end

      it 'exits the program' do
        expect do
          generator.send(:check_existing_key)
        end.to raise_error(SystemExit)
      end
    end
  end
end
