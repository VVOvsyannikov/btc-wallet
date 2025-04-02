# frozen_string_literal: true

class Result
  attr_reader :value, :message, :errors

  def initialize(success, value = nil, message = nil, errors = [])
    @success = success
    @value = value
    @errors = errors
    @message = message
  end

  def self.success(value, message)
    new(true, value, message)
  end

  def self.failure(errors)
    new(false, nil, nil, errors)
  end

  def success?
    @success
  end

  def failure?
    !@success
  end
end
