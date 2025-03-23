# frozen_string_literal: true

module DosHelper
  def start_dos(host_target:, port:, timeout: nil, type:)
    port = port.blank? ? nil : port.to_i
    timeout = timeout.blank? ? 2 : timeout.to_i

    raise CustomError.new(msg: "Invalid Command") if timeout > 5

    case type
    when 'udp_transport'
      raise CustomError.new(msg: "Invalid Command") if !(1..65535).include?(port)
      2.times.each do |e|
        p = Net::Ping::UDP.new(host_target, port, timeout)
        result = p.ping?
        raise CustomError.new(msg: "result: #{result}; exception: #{p.exception}") if !result
        break if Parameter.dos_slow
        sleep(0.5)
      end

    when 'tcp_transport'
      raise CustomError.new(msg: "Invalid Command") if !(1..65535).include?(port)
      # With a TCP ping simply try to open a connection. If we are successful,
      # assume success. In either case close the connection to be polite.
      2.times.each do |e|
        p = Net::Ping::TCP.new(host_target, port, timeout)
        result = p.ping?
        raise CustomError.new(msg: "result: #{result}; exception: #{p.exception}") if !result
        break if Parameter.dos_slow
        sleep(0.5)
      end

    when 'http_get'
      2.times.each do |e|
        url = [host_target, port].compact_blank.join(':')
        RestClient::Request.execute(method: :get, url: url, max_redirects: 1, timeout: timeout)
        break if Parameter.dos_slow
        sleep(0.5)
      end

    else
      raise CustomError.new(msg: "Invalid Command")
    end

  rescue RestClient::ExceptionWithResponse => e
    CustomError.new(msg: "result: #{e}")

  rescue StandardError => e
    return e if e.is_a?(CustomError)

    CustomError.new(msg: "result: #{e}")
  end
end