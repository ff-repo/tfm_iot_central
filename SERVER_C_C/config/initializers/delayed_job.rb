Delayed::Worker.max_attempts = 1   # Default is 25, reduces retry attempts
Delayed::Worker.max_run_time = 10.minutes  # Maximum time a job can run before being killed
Delayed::Worker.destroy_failed_jobs = true  # Retain failed jobs in the database for debugging
Delayed::Worker.sleep_delay = 10  # Delay before checking for new jobs
Delayed::Worker.read_ahead = 5  # Number of jobs to fetch at a time
Delayed::Worker.default_priority = 0  # Default priority (lower is higher priority)
Delayed::Worker.raise_signal_exceptions = :term  # Ensures graceful shutdown on signals
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))  # Custom log file
