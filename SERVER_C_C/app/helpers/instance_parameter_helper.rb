# frozen_string_literal: true

module InstanceParameterHelper
  def create_parameter_seeder(client_gateway)
    parameters_to_replace = {
      C_C_URI_TO_FILL: client_gateway.cc_setting['uri'],
      C_C_POOL_TO_FILL: client_gateway.cc_setting['pool'],
      C_C_CIPHER_KEY_TO_FILL: client_gateway.cc_setting['key'],
      C_C_CIPHER_IV_TO_FILL: client_gateway.cc_setting['iv'],
      C_C_TOKEN_TO_FILL: client_gateway.cc_setting['token'],
      CLIENT_C_URI_TO_FILL: client_gateway.client_setting['uri'],
      CLIENT_C_POOL_TO_FILL: client_gateway.client_setting['pool'],
      CLIENT_USER_TOKEN_TO_FILL: client_gateway.user_setting['token'],
    }

    file_content = File.read(Rails.root.join('lib', 'samples', 'api_gateway', 'parameter.rb'))
    parameters_to_replace.each do |key, val|
      file_content.gsub!(/\b#{key}\b/, '"' + val + '"')
    end

    output = Rails.root.join('tmp', 'deploy_site', 'api_gateway', 'parameter.rb')
    FileUtils.mkdir_p(File.dirname(output))
    File.delete(output) if File.exist?(output)
    File.write(output, file_content)

    return output
  end

  def create_user_seeder(client_gateway)
    parameters_to_replace = {
      USERNAME_TO_FILL: client_gateway.user_setting['username'],
      PASSWORD_TO_FILL: client_gateway.user_setting['password'],
      PASSWORD_CONF_TO_FILL: client_gateway.user_setting['password'],
      EMAIL_USER_TO_FILL: client_gateway.requester_email
    }

    file_content = File.read(Rails.root.join('lib', 'samples', 'api_gateway', 'user.rb'))
    parameters_to_replace.each do |key, val|
      file_content.gsub!(/\b#{key}\b/, '"' + val + '"')
    end

    output = Rails.root.join('tmp', 'deploy_site', 'api_gateway', 'user.rb')
    FileUtils.mkdir_p(File.dirname(output))
    File.delete(output) if File.exist?(output)
    File.write(output, file_content)

    return output
  end

  def create_settings(client_gateway)
    parameters_to_replace = {
      CLIENT_C_POOL_TO_FILL: client_gateway.client_setting['pool'],
      C_C_POOL_TO_FILL: client_gateway.cc_setting['pool']
    }

    file_content = File.read(Rails.root.join('lib', 'samples', 'api_gateway', 'settings.rb'))
    parameters_to_replace.each do |key, val|
      file_content.gsub!(/\b#{key}\b/, '"' + val + '"')
    end

    output = Rails.root.join('tmp', 'deploy_site', 'api_gateway', 'settings.rb')
    FileUtils.mkdir_p(File.dirname(output))
    File.delete(output) if File.exist?(output)
    File.write(output, file_content)

    return output
  end
end
