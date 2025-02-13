# frozen_string_literal: true

module Wallet
  class TransactionService # rubocop:disable Metrics/ClassLength
    class << self
      include Bitcoin::Builder

      SATOSHIS_PER_VBYTE = 1
      DUST_LIMIT = 546
      MIN_FEE = 500
      MAX_FEE = 10_000

      def send_bitcoin(amount:, to:)
        amount_satoshis = convert_to_satoshis(amount)
        return error_message('Amount is too small', DUST_LIMIT) if amount_satoshis < DUST_LIMIT
        return false unless check_balance(amount_satoshis)

        credentials = load_credentials
        create_and_broadcast_transaction(credentials, amount_satoshis, to)
      end

      private

      def load_credentials
        {
          address: WalletStorage.load_address,
          private_key: WalletStorage.load_private_key
        }
      end

      def convert_to_satoshis(amount)
        (amount.to_f * 100_000_000).to_i
      end

      def check_balance(amount_satoshis)
        balance = BalanceChecker.check
        return true if balance >= amount_satoshis

        puts "Insufficient funds. Current balance: #{balance} satoshis"
        false
      end

      def create_and_broadcast_transaction(credentials, amount, to)
        utxos = ApiConfig.api_service.get_address_utxos(credentials[:address])
        tx = build_transaction(utxos, credentials[:address], to, amount, credentials[:private_key])
        broadcast_transaction(tx)
      end

      def build_transaction(utxos, from, to, amount, private_key)
        key = Bitcoin::Key.from_base58(private_key)
        utxos_with_tx = fetch_utxos_with_tx(utxos)

        temp_tx = construct_transaction(utxos_with_tx, key, from, to, amount)
        fee = calculate_fee(temp_tx)
        change_amount = calculate_total_input(utxos) - amount - fee

        construct_transaction(utxos_with_tx, key, from, to, amount, change_amount)
      end

      def fetch_utxos_with_tx(utxos)
        utxos.map do |utxo|
          raw_tx_hex = ApiConfig.api_service.get_transaction_raw(utxo['txid'])
          {
            tx: Bitcoin::Protocol::Tx.new([raw_tx_hex].pack('H*')),
            index: utxo['vout'],
            value: utxo['value']
          }
        end
      end

      def construct_transaction(utxos_with_tx, key, from, to, amount, change_amount = 0) # rubocop:disable Metrics/ParameterLists
        build_tx do |t|
          utxos_with_tx.each { |input| add_input(t, input, key) }
          t.output do |o|
            o.value amount
            o.script { |s| s.recipient to }
          end
          if change_amount >= DUST_LIMIT
            t.output do |o|
              o.value change_amount
              o.script { |s| s.recipient from }
            end
          end
        end
      end

      def add_input(transaction, input, key)
        transaction.input do |i|
          i.prev_out input[:tx]
          i.prev_out_index input[:index]
          i.signature_key key
        end
      end

      def calculate_fee(tx)
        vsize = calculate_vsize(tx)
        [vsize * SATOSHIS_PER_VBYTE, MIN_FEE].max.clamp(0, MAX_FEE)
      end

      def calculate_vsize(tx)
        payload = tx.to_payload
        witness_size = tx.in.sum { |input| input.script_witness.to_payload.bytesize }
        non_witness_size = payload.bytesize - witness_size
        non_witness_size + (witness_size * 0.25).ceil
      end

      def calculate_total_input(utxos)
        utxos.sum { |utxo| utxo['value'] }
      end

      def broadcast_transaction(tx)
        tx_hex = tx.to_payload.unpack1('H*')
        response = ApiConfig.api_service.broadcast_transaction(tx_hex)
        puts "Transaction broadcasted: #{response}"
        true
      rescue StandardError => e
        puts "Failed to broadcast transaction: #{e.message}\nTransaction hex: #{tx_hex}"
        false
      end

      def error_message(message, limit)
        puts "Error: #{message}. Minimum amount is #{limit} satoshis (#{limit.to_f / 100_000_000} BTC)"
        false
      end
    end
  end
end
