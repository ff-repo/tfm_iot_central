Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost:3000'
    resource '*',
      headers: :any,
      methods: [:get, :options, :head],  # Ensure GET is allowed
      expose: ['Content-Disposition'],  # Needed for file downloads
      credentials: false
  end
end