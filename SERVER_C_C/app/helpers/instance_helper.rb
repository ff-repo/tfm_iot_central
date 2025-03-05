# frozen_string_literal: true

module InstanceHelper
  # heroku_app = 'facade-web' An unique identifier to identify the app (this is actually a name, and must be unique)
  def build_gateway_app(heroku_app)
    # 1: Run at once the deployment
    heroku = Heroku::ConnectorService.new
    heroku.build_app(heroku_app)
  end

  def deploy_gateway_app(heroku_app, client_gateway)
    # 1: Run at once the deployment
    heroku = Heroku::ConnectorService.new
    heroku.deploy_app(heroku_app, client_gateway)
  end

  # domain_name = 'tfmiotfacewebtest.diy'  # Don't ask weird domains with special symbols, use plain names
  # heroku_app = 'facade-web'
  def setup_dns(client_gateway_id, domain_name, heroku_app)
    client_gateway = ClientGateway.find(client_gateway_id)

    # 1: Enable ACM to leave control of certs to Heroku
    heroku = Heroku::ConnectorService.new
    acm_result = heroku.enable_certs(heroku_app)   # Enable the ACM to allow Heroku to manage the certs
    raise 'Fail on enabling ACM' if !acm_result[:success]


    # 2: Purchase Domain
    namecheap = Namecheap::ConnectorService.new
    available = namecheap.check_domain_availability(domain_name)
    raise 'Domain Name is not available' if !available[:available]
    purchase = namecheap.purchase_domain(domain_name)
    raise 'Cannot purchase' if !purchase[:success]


    # 3: Add Domain to heroku app to get the DNS resolutor
    # We need to add the custom domain in order to allow heroku to generate a unqiue DNS resolver for our application
    full_domain = client_gateway.format_uri_to_access  # We need to do this since the DNS is generate explicitly for www.something.com and the certs are so restricted to the name
    heroku.add_custom_domain(full_domain, heroku_app)
    heroku_resolver_app = heroku.get_heroku_dns_target(heroku_app)
    raise 'Heroku App may not available' if heroku_resolver_app.blank?
    heroku_app_dns = heroku_resolver_app[:cname]


    # 4: Now we map and link the domain resolutor with the Heroku app
    update_domain = namecheap.setup_domain_with_heroku_app(domain_name, heroku_app_dns)
    raise 'Cannot setup the heroku domain into namecheap' if !update_domain[:success]

    # 5: Welcome!!
    puts "\n It will take 10 - 20 min to get synced the records\n"

  end

  def shut_gateway_app(heroku_app)
    heroku = Heroku::ConnectorService.new
    heroku.shut_app(heroku_app)
  end

  # Only for clean the DNS records, because the domain still active for us
  def shut_dns(domain_name)
    namecheap = Namecheap::ConnectorService.new
    update_domain = namecheap.clean_domain_with_heroku_app(domain_name)
    return CustomError.new(message: 'Cannot cleanup the records in namecheap') if !update_domain[:success]
  end
end