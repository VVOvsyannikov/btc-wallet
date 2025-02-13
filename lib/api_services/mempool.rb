# frozen_string_literal: true

module ApiServices
  class Mempool < Base
    class << self
      def get_address_utxos(address)
        get_request("/address/#{address}/utxo")
      end

      def get_transaction(txid)
        get_request("/tx/#{txid}")
      end

      def get_transaction_raw(txid)
        uri = URI("#{ApiConfig.api_url}/tx/#{txid}/raw")
        response = Net::HTTP.get(uri)
        response.unpack1('H*')
      end

      def broadcast_transaction(tx_hex)
        post_request('/tx', tx_hex)
      end

      private

      def get_request(path)
        uri = URI("#{ApiConfig.api_url}#{path}")
        response = Net::HTTP.get(uri)
        JSON.parse(response)
      end

      def post_request(path, data)
        response = send_request(path, data)
        handle_response(response)
      end

      def send_request(path, data)
        uri = URI("#{ApiConfig.api_url}#{path}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Post.new(uri.path)
        request['Content-Type'] = 'text/plain'
        request.body = data

        http.request(request)
      end

      def handle_response(response)
        raise "HTTP Error #{response.code}: #{response.body}" unless response.code == '200'

        JSON.parse(response.body)
      rescue JSON::ParserError
        response.body
      end
    end
  end
end
