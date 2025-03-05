# frozen_string_literal: true

# Only lightweight pings
module PingsHelper
  include UtilsHelper

  def start_ping(host_target:, port: nil, timeout: nil, type: nil)
    port = port.blank? ? nil : port.to_i
    timeout = timeout.blank? ? 5 : timeout.to_i

    content_result = ''
    case type
    when 'udp'
      p = Net::Ping::UDP.new(host_target, port, timeout)
      result = p.ping?

      raise CustomError.new(msg: "result: #{result}; exception: #{p.exception.to_s}") if !result

    when 'http_head'
      p = Net::Ping::HTTP.new(host_target, port, timeout)
      p.follow_redirect = false
      result = p.ping?

      raise CustomError.new(msg: "result: #{result}; exception: #{p.exception.to_s}") if !result

    when 'http_get'
      url = [host_target, port].compact_blank.join(':')
      response = RestClient::Request.execute(method: :get, url: url, max_redirects: 0, timeout: timeout)
      body = response.body
      result = body.present? ? body.gsub(/<!--.*?-->/m, '').first(120) : ''

      raise CustomError.new(msg: "result: #{result}; exception: #{p.exception.to_s}") if !result

    else
      raise CustomError.new(msg: "Invalid Command")
    end

    custom_out(success: true, result: result)

  rescue RestClient::ExceptionWithResponse => e
    CustomError.new(msg: "result: #{e}")

  rescue StandardError => e
    return e if e.is_a?(CustomError)

    CustomError.new(msg: "result: #{e}")
  end
end