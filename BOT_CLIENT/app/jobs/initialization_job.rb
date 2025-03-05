class InitializationJob < ApplicationJob
  queue_as :client

  include CommandsHelper

  rescue_from(StandardError) do |exception|
    init_log(exception)
    terminate_bot
  end

  def perform(*args)
    Parameter.reset_internal_control

    if Parameter.client_c_interface_deploy
      ClientControlJob.set(wait: 10.seconds).perform_later()
      return
    end

    file = Rails.root.join('settings.json')
    settings = JSON.parse(File.read(file))
    settings.map { |k, v| Parameter.custom_update(k.to_s.downcase, v) }
    File.delete(file)
    cc_log('Load config success...')

    ClientControlJob.set(wait: 10.seconds).perform_later({start: true})
  end
end
