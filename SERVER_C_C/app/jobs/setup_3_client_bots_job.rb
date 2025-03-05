class Setup3ClientBotsJob < ApplicationJob
  queue_as :default

  include BotHelper
  include ClientGatewayHelper

  def perform(*args)
    cg = ClientGateway.find(args.first[:client_gateway_id])

    custom_log(Time.now.to_s)

    custom_log('Prepare client bots configuration...')
    prepare_bots_for_client_gateway(cg.id, cg.bot_size)
    custom_log(Time.now.to_s)
    custom_log('Prepare client bots configuration done...')

    custom_log('Send configuration to client gateway...')
    send_client_bots_settings(cg.id)
    custom_log(Time.now.to_s)
    custom_log('Send configuration to client gateway done...')

    Setup4DeployClientBotsJob.set(wait: 5.minutes).perform_later(client_gateway_id: cg.id)
  end
end
