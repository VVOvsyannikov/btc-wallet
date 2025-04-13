# frozen_string_literal: true

module Wallet
  class Send < Base
    class << self
      include Bitcoin::Builder

      SATOSHIS_PER_VBYTE = 1
      DUST_LIMIT = 546
      MIN_FEE = 500
      MAX_FEE = 10_000

      def call(options)
        options.amount = convert_to_satoshis(options.amount)

        errors = validate_amount_and_balance(options)

        return Result.failure(errors) unless errors.empty?

        result = make_transaction(options)
        Result.success(true, "Transaction broadcasted #{result}")
      rescue StandardError
        Result.failure(error_message)
      end

      private

      def convert_to_satoshis(amount)
        (BigDecimal(amount) * 100_000_000).to_i
      end

      def validate_amount_and_balance(options)
        errors = []
        errors << "Amount must be bigger than #{DUST_LIMIT / 100_000_000} BTC" if options.amount < DUST_LIMIT

        balance = Balance.call(options).value
        if balance <= options.amount
          errors << "Insufficient funds. Current balance: #{balance} satoshis, amount: #{options.amount} satoshis"
        end

        errors
      end

      def make_transaction(options)
        utxos = ApiConfig.api_service.get_address_utxos(options.from)
        tx = build_transaction(utxos, options)
        broadcast_transaction(tx)
      end

      def build_transaction(utxos, options)
        private_key = load_private_key(options.from)
        key = Bitcoin::Key.from_base58(private_key)
        utxos_with_tx = fetch_utxos_with_tx(utxos)

        temp_tx = construct_transaction(utxos_with_tx, key, options)
        fee = calculate_fee(temp_tx)
        change_amount = calculate_total_input(utxos) - options.amount - fee

        construct_transaction(utxos_with_tx, key, options, change_amount)
      end

      def load_private_key(address)
        KeyStorage.load_private_key(address)
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

      def construct_transaction(utxos_with_tx, key, options, change_amount = 0)
        build_tx do |t|
          utxos_with_tx.each { |input| add_input(t, input, key) }
          t.output do |o|
            o.value options.amount
            o.script { |s| s.recipient options.to }
          end
          if change_amount >= DUST_LIMIT
            t.output do |o|
              o.value change_amount
              o.script { |s| s.recipient options.from }
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
        witness_size = tx.in.sum { |input| input.script_witness&.to_payload&.bytesize.to_i }
        non_witness_size = payload.bytesize - witness_size
        non_witness_size + (witness_size * 0.25).ceil
      end

      def calculate_total_input(utxos)
        utxos.sum { |utxo| utxo['value'] }
      end

      def broadcast_transaction(tx)
        tx_hex = tx.to_payload.unpack1('H*')
        ApiConfig.api_service.broadcast_transaction(tx_hex)
      end
    end
  end
end
