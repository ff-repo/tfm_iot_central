# frozen_string_literal: true

module Heroku
  class ConnectorService < ApplicationService
    require 'net/ssh'
    require 'net/scp'
    require 'net/ssh/proxy/socks5'

    include InstanceParameterHelper

    attr_accessor :result

    def initialize
      @result = nil
      proxy_uri = URI.parse("socks://#{FIXIE_SOCKS_HOST}")
      @socks_proxy = Net::SSH::Proxy::SOCKS5.new(
        proxy_uri.host,
        proxy_uri.port,
        user: proxy_uri.user,
        password: proxy_uri.password,
        )
      @key_file = Rails.root.join('tmp', Parameter.deployer_file)
      @remote_path = './deploy_site/gateway-client'
    end

    # @param domain <string> The complete domain to access. e.g. www.google.com
    # @param heroku_app <string> Only the name app. e.g. facade-web
    # @note Need to wit until heroku assign the unique DNS to resolve in their side
    def add_custom_domain(domain, heroku_app)
      raise CustomError.new(message: 'Lack of params') if domain.blank? || heroku_app.blank?
      @result = run_heroku_command("heroku domains:add #{domain} --app #{heroku_app}")

      return true
    end

    # Fetches the DNS target (CNAME) required for Heroku setup
    def get_heroku_dns_target(heroku_app)
      @result = run_heroku_command("heroku domains --json --app #{heroku_app}")
      return nil if @result.blank?

      domains = JSON.parse(@result)
      return nil if domains.blank?

      cname_resolver = domains.find { |e| e if (e['cname'].present? && e['status'] == 'succeeded') }
      return nil if cname_resolver.blank?

      cname_resolver.with_indifferent_access
    end

    def enable_certs(heroku_app)
      @result = run_heroku_command("heroku certs:auto:enable --app #{heroku_app}")
      {
        success: @result.present?,
        error: @result.present? ? nil : 'General error on activating ACM in heroku'
      }
    end

    def stop_app(heroku_app)
      @result = run_heroku_command("heroku ps:scale web=0 --app #{heroku_app}")
      {
        success: @result.present?,
        error: @result.present? ? nil : 'General error on activating ACM in heroku'
      }
    end

    # Database will take time to deploy
    def build_app(heroku_app)
      get_key
      output = nil
      Net::SSH.start(Parameter.deployer_host, Parameter.deployer_user, keys: [@key_file], passphrase: Parameter.deployer_passphrase, proxy: @socks_proxy, timeout: 30) do |ssh|
        output = ssh.exec!("echo \"$(date '+%Y-%m-%d %H:%M:%S') - $(whoami) - Event Build\" >> login_access.txt")
        print_ssh_output(output)
        output = ssh.exec!("cd #{@remote_path} && git checkout main && git reset --hard && git pull origin main && git remote remove heroku; git checkout -b feat/#{heroku_app}")
        print_ssh_output(output)
        output = ssh.exec!("cd #{@remote_path} && heroku apps:info --app #{heroku_app}")
        print_ssh_output(output)
        if output.include?("Couldn't find that")
          output = ssh.exec!("cd #{@remote_path} && heroku create #{heroku_app}")
          print_ssh_output(output)
        else
          raise 'Found an App with the same specification, check the name reference availability first'
        end

        output = ssh.exec!("cd #{@remote_path} && git remote add heroku https://git.heroku.com/#{heroku_app}.git")
        print_ssh_output(output)
        output = ssh.exec!("cd #{@remote_path} && heroku config:set RAILS_ENV=production --app #{heroku_app} && heroku config:set RACK_ENV=production --app #{heroku_app}")
        print_ssh_output(output)
        output = ssh.exec!("cd #{@remote_path} && heroku config:set SECRET_KEY_BASE=#{SecureRandom.hex(64)} --app #{heroku_app}")
        print_ssh_output(output)
        output = ssh.exec!("cd #{@remote_path} && heroku addons:create heroku-postgresql:essential-0 --app #{heroku_app}")
        print_ssh_output(output)
      end

      clean_up

      return output

    rescue  StandardError => e
      clean_up
      report_error(e)
      raise CustomError.new(code: '2001', message: "Could not build app: #{e.to_s}")
    end

    # Require the app is build, database is built and linked
    def deploy_app(heroku_app, client_gateway)
      parameter_path = create_parameter_seeder(client_gateway)
      user_path = create_user_seeder(client_gateway)
      setting_path = create_settings(client_gateway)

      get_key
      output = nil
      Net::SSH.start(Parameter.deployer_host, Parameter.deployer_user, keys: [@key_file], passphrase: Parameter.deployer_passphrase, proxy: @socks_proxy, timeout: 30) do |ssh|
        output = ssh.exec!("echo \"$(date '+%Y-%m-%d %H:%M:%S') - $(whoami) - Event Deployment\" >> login_access.txt")
        print_ssh_output(output)
        output = ssh.exec!("cd #{@remote_path} && git checkout feat/#{heroku_app}")
        print_ssh_output(output)

        ssh.scp.upload!(setting_path.to_s, "#{@remote_path}/config/initializers/")
        ssh.scp.upload!(user_path.to_s, "#{@remote_path}/db/seeds/")
        ssh.scp.upload!(parameter_path.to_s, "#{@remote_path}/db/seeds/")
        puts "Outssh==> *Uploading all files at #{Time.now}"

        output = ssh.exec!("cd #{@remote_path} && git add . && git commit -m '#{heroku_app}'")
        print_ssh_output(output)
        output = ssh.exec!("cd #{@remote_path} && git push heroku feat/#{heroku_app}:main")
        print_ssh_output(output)
        sleep(10)
        output = ssh.exec!("cd #{@remote_path} && heroku run rails db:migrate db:seed --app #{heroku_app}")
        print_ssh_output(output)
        output = ssh.exec!("cd #{@remote_path} && git checkout main && git branch -D feat/#{heroku_app} && git remote remove heroku")
        print_ssh_output(output)
      end
      clean_up

      File.delete(setting_path) if File.exist?(setting_path)
      File.delete(user_path) if File.exist?(user_path)
      File.delete(parameter_path) if File.exist?(parameter_path)

      return output

    rescue  StandardError => e
      clean_up
      report_error(e)
      raise CustomError.new(code: '2001', message: "Could not build app: #{e.to_s}")
    end

    def shut_app(heroku_app)
      get_key

      Net::SSH.start(Parameter.deployer_host, Parameter.deployer_user, keys: [@key_file], passphrase: Parameter.deployer_passphrase, proxy: @socks_proxy, timeout: 30) do |ssh|
        output = ssh.exec!("echo \"$(date '+%Y-%m-%d %H:%M:%S') - $(whoami) - Event Deletion\" >> login_access.txt")
        output = ssh.exec!("heroku apps:destroy --app #{heroku_app} --confirm #{heroku_app}")
        print_ssh_output(output)
        raise 'No App with the references to delete was found' if output.include?('Error ID: not_found')
        output = ssh.exec!("heroku apps:info --app #{heroku_app}")
        print_ssh_output(output)
        raise 'App is not deleted' if output.include?('heroku_app')
      end

      clean_up
      nil

    rescue  StandardError => e
      clean_up
      return CustomError.new(code: '2001', message: "Trying to delete app generate message: #{e.to_s}")
    end

    private

    # Executes a Heroku command over SSH
    def run_heroku_command(command)
      deployer = Deployer::ConnectorService.new
      result = deployer.run(command)

      raise result if result.is_a?(CustomError)

      result
    end

    def run(command)
      get_key
      output = nil
      Net::SSH.start(Parameter.deployer_host, Parameter.deployer_user, keys: [@key_file], passphrase: Parameter.deployer_passphrase, proxy: @socks_proxy, timeout: 30) do |ssh|
        output = ssh.exec!(command)
      end
      clean_up

      return output

    rescue  StandardError => e
      clean_up
      raise 'Cannot connect'
    end

    def get_key
      s3 = AwsIntegration::ConnectorService.new
      s3.download_object(@key_file)
    end

    def clean_up
      File.delete(@key_file)
    end
  end
end


