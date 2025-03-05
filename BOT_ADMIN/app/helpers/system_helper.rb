# frozen_string_literal: true

module SystemHelper
  def run_shell(command)
    output = `#{command}`
    output
  rescue StandardError => e
    CustomError(msg: e)
  end
end