# frozen_string_literal: true

module ApiServices
  class Blockstream < Base
    class << self
      def get_address_utxos(address)
        get_request("/address/#{address}/utxo")
      end

      def broadcast_transaction(tx_hex)
        post_request('/tx', tx_hex)
      end

      def get_transaction_raw(txid)
        uri = URI("#{ApiConfig.api_url}/tx/#{txid}/raw")
        response = Net::HTTP.get(uri)
        response.unpack1('H*')
      end

      private

      def get_request(path)
        uri = URI("#{ApiConfig.api_url}#{path}")
        response = Net::HTTP.get(uri)
        JSON.parse(response)
      end

      def post_request(path, data)
        uri = URI("#{ApiConfig.api_url}#{path}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Post.new(uri.path)
        request.body = data

        response = http.request(request)
        JSON.parse(response.body)
      end
    end
  end
end
