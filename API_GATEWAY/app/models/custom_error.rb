# frozen_string_literal: true

class CustomError < StandardError
  attr_accessor :message, :code, :fatal

  def initialize(message: 'Generic Error', code: '0001', fatal: false)
    super(message)
    @code = code
    @fatal = fatal
  end
end
