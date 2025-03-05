# frozen_string_literal: true

module UtilsHelper
  def custom_out(success: false, result: nil)
    {
      success: success,
      result: result
    }
  end
end