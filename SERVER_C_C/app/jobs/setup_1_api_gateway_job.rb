class Setup1ApiGatewayJob < ApplicationJob
  queue_as :default

  include InstanceHelper

  def perform(*args)
    cg = ClientGateway.find(args.first[:client_gateway_id])
    heroku_app = cg.external_app_code
    domain_name = cg.domain

    custom_log(Time.now.to_s)
    custom_log(heroku_app)
    custom_log(domain_name)

    # 1: Build dependencies App
    custom_log('Building gateway...')
    build_gateway_app(heroku_app)
    custom_log(Time.now.to_s)
    sleep(150)
    custom_log('Build gateway done')

    # 2: Deploy App
    custom_log('Deploying gateway...')
    deploy_gateway_app(heroku_app, cg)
    custom_log(Time.now.to_s)
    sleep(60)
    custom_log('Deploy gateway done')

    Setup2DnsJob.set(wait: 1.minutes).perform_later(client_gateway_id: cg.id)
  end
end
