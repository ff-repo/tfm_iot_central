# frozen_string_literal: true

class CustomError
  attr_accessor :code, :msg

  GENERIC = '000'
  DOS_ONGOING = '100'
  FATAL = '999'

  def initialize(code: GENERIC, msg: '')
    @code = code
    @msg = msg
  end

  def generic_error?
    @code == GENERIC
  end

  def fatal_error?
    @code == FATAL
  end

  def dos_ongoing?
    @code == DOS_ONGOING
  end
end
