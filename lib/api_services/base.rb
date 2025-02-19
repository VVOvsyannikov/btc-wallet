# frozen_string_literal: true

module ApiServices
  class Base
    class << self
      def get_address_utxos(address)
        raise NotImplementedError
      end

      def get_transaction(txid)
        raise NotImplementedError
      end

      def broadcast_transaction(tx_hex)
        raise NotImplementedError
      end

      def get_transaction_raw(txid)
        raise NotImplementedError
      end
    end
  end
end
