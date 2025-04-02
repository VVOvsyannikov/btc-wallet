# frozen_string_literal: true

require 'zeitwerk'

class ZeitwerkConfig
  class << self
    def setup
      loader = Zeitwerk::Loader.new
      loader.push_dir(__dir__.to_s)
      loader.push_dir("#{__dir__}/../lib")
      loader.setup
      loader.eager_load
      loader
    end
  end
end
