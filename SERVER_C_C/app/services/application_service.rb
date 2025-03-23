# frozen_string_literal: true

class ApplicationService
  def self.call(*args, &block)
    new(*args, &block).call
  end

  private

  # A centrilize method to report errors either a 3rd party or standard output console
  def report_error(e)
    if Rails.env.development?
      puts "Report error: #{e}"
    else
      Bugsnag.notify(e)
      e.instance_eval { def skip_bugsnag; true; end }
    end
  end

  def print_ssh_output(message)
    puts "service(#{self.class.name.downcase})[debug]{notice}: #{message}"
  end

  def print_generic_output(message)
    puts "service(#{self.class.name.downcase})[debug]{notice}: #{message}"
  end
end
