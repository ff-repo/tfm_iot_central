# frozen_string_literal: true

class BotCommandPool < ApplicationRecord
  scope :pending_to_send, -> { where(sent_at: nil).order(:id) }
  scope :sent, -> { where.not(sent_at: nil) }

  belongs_to :bot

  def self.get_last(limit: 100)
    order(id: :desc).limit(limit)
  end

  def self.pop_pending
    e = pending_to_send.first
    e.update(sent_at: Time.now) if e.present?

    e
  end

  def self.available_commands
    {
      '001': {
        name: 'udp_ping',
        description: 'Send a package UDP to check response',
        type: 'ping',
        type_2: 'udp'
      },
      '002': {
        name: 'http_head_ping',
        description: 'Send a HTTP Head request to test connection',
        type: 'ping',
        type_2: 'http_head'
      },
      '003': {
        name: 'http_get_content',
        description: 'Try a HTTP Get request to bring content',
        type: 'ping',
        type_2: 'http_get'
      },
      '004': {
        name: 'udp_dos',
        description: 'Same as UDP ping, just many times and sequential',
        type: 'dos',
        type_2: 'dos_start',
        type_3: 'udp'
      },
      '005': {
        name: 'tcp_dos',
        description: 'Try many sequential test connections by using TCP',
        type: 'dos',
        type_2: 'dos_start',
        type_3: 'tcp'
      },
      '006': {
        name: 'http_get_dos',
        description: 'Same as HTTP Get Content, just many times and sequential',
        type: 'dos',
        type_2: 'dos_start',
        type_3: 'http_get'
      },
      '007': {
        name: 'dos_status',
        description: 'Check the status of DOS',
        type: 'dos',
        type_2: 'dos_status'
      },
      '008': {
        name: 'dos_stop',
        description: 'Stop the DOS',
        type: 'dos',
        type_2: 'dos_stop'
      },
      '009': {
        name: 'dns_lookup',
        description: 'A simple resolver of dns that return simple info',
        type: 'dns',
        type_2: 'lookup'
      }

    }
  end
end
