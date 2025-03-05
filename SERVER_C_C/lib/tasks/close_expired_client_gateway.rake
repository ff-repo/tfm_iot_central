namespace :close_expired_client_gateway do
  desc 'Shutdown Client Gateway if has ended the period of usage'
  task :run => :environment do
    include InstanceHelper
    include ClientGatewayHelper

    ClientGateway.only_actives.terminated.each do |cg|
      turn_off_client_bots(cg)
      sleep(2)

      if cg.external_app_code.present?
        result_heroku = shut_gateway_app(cg.external_app_code)
        raise result_heroku if result_heroku.is_a?(CustomError)
      end

      if cg.domain.present?
        result_domain = shut_dns(cg.domain)
        raise result_domain if result_domain.is_a?(CustomError)
      end

      cg.update(active: false)
    end

  rescue StandardError => e
    puts "rake_task(close_expired_client_gateway)[debug]{error}: #{e.to_s}"
    Bugsnag.notify(e) if !Rails.env.development?
  end
end
