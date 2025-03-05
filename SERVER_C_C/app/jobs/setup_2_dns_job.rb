class Setup2DnsJob < ApplicationJob
  queue_as :default

  include InstanceHelper

  def perform(*args)
    cg = ClientGateway.find(args.first[:client_gateway_id])
    heroku_app = cg.external_app_code
    domain_name = cg.domain

    custom_log(Time.now.to_s)
    custom_log(heroku_app)
    custom_log(domain_name)

    custom_log('DNS Linking...')
    setup_dns(cg.id, domain_name, heroku_app)
    custom_log(Time.now.to_s)
    custom_log('DNS Link done')

    cg.update(
      implemented_at: Time.now,
      active: true
    )
    cg.api_token.update(active: true)

    Setup3ClientBotsJob.set(wait: 25.minutes).perform_later(client_gateway_id: cg.id)
  end
end

