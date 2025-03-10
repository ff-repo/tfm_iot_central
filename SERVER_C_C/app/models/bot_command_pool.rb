# frozen_string_literal: true

class BotCommandPool < ApplicationRecord
  scope :pending_to_send, -> { where(sent_at: nil).order(:id) }
  scope :sent, -> { where.not(sent_at: nil) }

  belongs_to :bot

  COMMANDS_TYPE_CODES = {
    SYSTEM_COMMANDS: '001',
    CLIENT_DEPLOYMENT: '002',
    CLIENT_SHUT_DEPLOYMENT: '003',
    CLIENT_STATUS: '004',
    REMOVE_BOT: '999'
  }.with_indifferent_access

  def self.get_last(limit: 100)
    order(id: :desc).limit(limit)
  end

  def self.pop_pending
    e = pending_to_send.first
    e.update(sent_at: Time.now) if e.present?

    e
  end

  before_save do |e|
    e.result = {} if e.result.blank?
    e.metadata = {} if e.metadata.blank?
  end

  def self.available_commands
    {
      '001': {
        name: 'system_commands',
        description: 'Send commands to run on OS system',
        type: 'system'
      },
      '002': {
        name: 'client_deployment',
        description: 'Deploy a client app to connect to the Client Gateway',
        type: 'deploy',
        type_2: 'bot_client'
      },
      '003': {
        name: 'client_shut_deployment',
        description: 'Shutdown the client app to connect to the Client Gateway',
        type: 'undeploy',
        type_2: 'bot_client'
      },
      '004': {
        name: 'client_check_status',
        description: 'Check the status of client app (only verify if it is installed)',
        type: 'status',
        type_2: 'bot_client'
      },
      '005': {
        name: 'renew_key',
        description: 'Renew the private key and IV for obfuscation',
        type: 'renew',
        type_2: 'bot_admin'
      },
      '999': {
        name: 'remove_bot',
        description: 'Remove the bot',
        type: 'autokill',
        type_2: 'bot_admin'
      }
    }.with_indifferent_access
  end
end
