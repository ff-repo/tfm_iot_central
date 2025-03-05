class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  rescue_from(StandardError) do |e|
    Bugsnag.notify(e)
    e.instance_eval { def skip_bugsnag; true; end }
  end

  private

  def custom_log(exception)
    log_file = Rails.root.join('log', 'jobs.log')
    File.truncate(log_file, 0) if File.exist?(log_file) && (File.readlines(log_file).size > 20)
    logger = Logger.new(log_file)
    logger.info "#{exception}"
  end
end
