# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ArgumentParser do
  let(:command) { nil }
  let(:amount) { nil }
  let(:address) { nil }
  let(:options) do
    Struct.new(:command, :amount, :from, :to).new(command:, amount:, from: address, to: address)
  end
  let(:result) { described_class.call }

  before do
    allow(Bitcoin).to receive(:valid_address?).with(valid_address).and_return(true)
    allow(Bitcoin).to receive(:valid_address?).with(invalid_address).and_return(false)
    allow(described_class).to receive(:parse_options).and_return(options)
  end

  describe '#generate command' do
    let(:command) { 'generate' }

    context 'when without arguments' do
      it { expect(result).to be_success }
    end

    context 'when extra arguments are provided' do
      let(:amount) { 'some_amount' }
      let(:address) { 'some_address' }

      it { expect(result).to be_failure }

      it 'returns error message' do
        expect(result.errors).to include('Command generate do not allow any arguments')
      end
    end
  end

  describe '#balance command' do
    let(:command) { 'balance' }

    context 'when from argument provided' do
      let(:address) { valid_address }

      before { options.to = nil }

      it { expect(result).to be_success }
    end

    context 'when no from argument provided' do
      it { expect(result).to be_failure }

      it 'returns error message' do
        expect(result.errors).to include('Required from=<address> (wallet address) argument',
                                         'Invalid from=<address> argument')
      end
    end

    context 'when invalid from argument' do
      let(:address) { invalid_address }

      before { options.to = nil }

      it { expect(result).to be_failure }

      it 'returns error message' do
        expect(result.errors).to include('Required from=<address> (wallet address) argument',
                                         'Invalid from=<address> argument')
      end
    end

    context 'when extra arguments are provided' do
      let(:amount) { 'some_amount' }
      let(:address) { valid_address }

      it { expect(result).to be_failure }

      it 'returns error message' do
        expect(result.errors).to include('Command balance do not allow argument amount=<amount>',
                                         'Command balance do not allow argument to=<address>')
      end
    end
  end

  describe '#send command' do
    let(:command) { 'send' }
    let(:address) { valid_address }

    context 'when valid arguments' do
      let(:amount) { '0.0075' }

      it { expect(result).to be_success }
    end

    context 'when if amount is missing' do
      it { expect(result).to be_failure }

      it 'returns error message' do
        expect(result.errors).to include('Required amount=<amount> argument',
                                         'Amount must be a number in BTC (not Satoshis)',
                                         'Amount must be greater than 0')
      end
    end

    context 'when amount is not a number' do
      let(:amount) { 'foo' }

      it { expect(result).to be_failure }

      it 'returns error message' do
        expect(result.errors).to include('Amount must be a number in BTC (not Satoshis)',
                                         'Amount must be greater than 0')
      end
    end

    context 'when amount is is zero' do
      let(:amount) { '0' }

      it { expect(result).to be_failure }

      it 'returns error message' do
        expect(result.errors).to include('Amount must be greater than 0')
      end
    end

    context 'when invalid address' do
      let(:address) { invalid_address }

      it { expect(result).to be_failure }

      it 'returns error message' do
        expect(result.errors).to include('Required amount=<amount> argument', 'Required from=<address> argument',
                                         'Required to=<address> argument', 'Amount must be greater than 0',
                                         'Invalid from=<address> argument', 'Invalid to=<address> argument')
      end
    end
  end
end
