# frozen_string_literal: true

module CustomLoggerHelper
  def init_log(exception)
    custom_log('init.log', exception)
  end

  def cc_log(exception)
    custom_log('cc.log', exception)
  end

  def custom_log(log_name, exception)
    log_file = Rails.root.join('log', log_name)
    FileUtils.mkdir_p(File.dirname(log_file))
    File.truncate(log_file, 0) if File.exist?(log_file) && (File.readlines(log_file).size > 20)
    logger = Logger.new(log_file)
    logger.info "#{exception}"
  end
end