# frozen_string_literal: true

module ApiConfig
  class << self
    attr_accessor :api_url, :api_service

    def configure
      yield self
    end
  end
end

ApiConfig.configure do |config|
  config.api_url = 'https://mempool.space/signet/api'
  config.api_service = ApiServices::Mempool
end
