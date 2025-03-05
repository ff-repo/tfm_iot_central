Delayed::Worker.destroy_failed_jobs = true
Delayed::Worker.sleep_delay = 1
Delayed::Worker.max_attempts = 1
Delayed::Worker.max_run_time = 1.minutes
Delayed::Worker.read_ahead = 5
Delayed::Worker.default_queue_name = 'client'
Delayed::Worker.delay_jobs = true
Delayed::Worker.raise_signal_exceptions = :term
Delayed::Worker.logger = Logger.new(nil)