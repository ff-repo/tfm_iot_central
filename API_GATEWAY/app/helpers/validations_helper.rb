# frozen_string_literal: true

module ValidationsHelper
  def valid_host?(ip_or_domain)
    ipv4_regex = /\A\d{1,3}(\.\d{1,3}){3}\z/
    domain_regex = /\A([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}\z/

    if ip_or_domain.match?(ipv4_regex)
      ip = IPAddr.new(ip_or_domain) rescue nil

      forbidden = [
        IPAddr.new('10.0.0.0/8'),
        IPAddr.new('172.16.0.0/12'),
        IPAddr.new('192.168.0.0/16'),
        IPAddr.new('127.0.0.0/8'),
        IPAddr.new('169.254.0.0/16'),
      ]

      return true if !forbidden.any? { |e| e.include?(ip) }

      raise CustomError.new(message: "Bad IP address: #{ip_or_domain}")

    elsif ip_or_domain.match?(domain_regex)
      return true if !ip_or_domain.include?('localhost')

      raise CustomError.new(message: "Bad Domain: #{ip_or_domain}")
    end

    raise CustomError.new(message: "Bad host: #{ip_or_domain}")
  end

  def valid_port?(port)
    port.to_s.match?(/\A\d+\z/) && port.to_i.between?(1, 65535)
  end
end