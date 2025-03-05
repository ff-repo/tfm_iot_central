# frozen_string_literal: true

class CommandPresenter < BasePresenter
  attr_accessor :code, :description

  def initialize(code, command)
    @code = code
    @description = command[:description]
  end

  def resp_json
    {
      code: @code,
      description: @description
    }
  end
end