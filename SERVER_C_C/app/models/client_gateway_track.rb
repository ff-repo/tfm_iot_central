# frozen_string_literal: true

class ClientGatewayTrack < ApplicationRecord
  belongs_to :client_gateway

  def self.create_as_notice(description)
    create(event_description: description, event_type: 'NOTICE')
  end

  def self.create_as_invalid_command(description)
    create(event_description: description, event_type: 'INVALID_COMMAND')
  end
end
