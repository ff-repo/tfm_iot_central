# frozen_string_literal: true

module Deployer
  class ConnectorService < ApplicationService
    require 'net/ssh'
    require 'net/ssh/proxy/socks5'

    def initialize
      proxy_uri = URI.parse("socks://#{FIXIE_SOCKS_HOST}")
      @socks_proxy = Net::SSH::Proxy::SOCKS5.new(
        proxy_uri.host,
        proxy_uri.port,
        user: proxy_uri.user,
        password: proxy_uri.password,
      )
      @key_file = Rails.root.join('tmp', Parameter.deployer_file)
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

    private

    def get_key
      s3 = AwsIntegration::ConnectorService.new
      s3.download_object(@key_file)
    end

    def clean_up
      File.delete(@key_file)
    end
  end
end
