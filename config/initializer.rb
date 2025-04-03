# frozen_string_literal: true

require 'zeitwerk'
require 'bundler/setup'
require 'bigdecimal'
require 'bitcoin'
require 'json'
require 'fileutils'
require 'net/http'
require 'optparse'
require 'ostruct'
require 'stringio'

class Initializer
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

Initializer.setup
Bitcoin.network = :testnet3
