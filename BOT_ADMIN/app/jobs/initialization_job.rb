class InitializationJob < ApplicationJob
  queue_as :admin

  include OsHelper
  include CommandsHelper

  rescue_from(StandardError) do |exception|
    init_log(exception)
    terminate_bot
  end

  def perform(*args)
    Parameter.reset_internal_control

    if Parameter.c_c_interface_deploy
      CommandControlJob.set(wait: 5.seconds).perform_later()
      return
    end

    payload = get_reg_payload(host_info)
    settings = register_bot(payload)

    raise settings if settings.is_a?(CustomError)
    settings.map { |k, v| Parameter.custom_update(k.to_s.downcase, v) }
    cc_log('Load config success...')

    CommandControlJob.set(wait: 5.seconds).perform_later({start: true})
  end
end
