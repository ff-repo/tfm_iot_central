class Setup4DeployClientBotsJob < ApplicationJob
  queue_as :default

  include BotHelper

  def perform(*args)
    cg = ClientGateway.find(args.first[:client_gateway_id])
    custom_log(Time.now.to_s)

    custom_log('Load in the command pool to deploy client bot...')
    deploy_client_bots(cg.id)
    custom_log(Time.now.to_s)
    custom_log('Load in the command pool to deploy client bot done...')
  end
end
