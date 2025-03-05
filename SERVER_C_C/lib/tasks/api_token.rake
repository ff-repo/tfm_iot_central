namespace :api_token do
  desc 'Generate api Token for Entity'
  task :generate_for_entity => :environment do
    include ApiTokenHelper

    rewrite = false

    Notifier.all.each do |e|
      if rewrite
        e.api_token.update(token: generate_token)
      end

      next if e.api_token.present?
      e.create_api_token(token: generate_token, description: 'Web notifier', active: true)
    end

    User.all.each do |e|
      if rewrite
        e.api_token.update(token: generate_token)
      end

      next if e.api_token.present?
      e.create_api_token(token: generate_token, description: 'User connection', active: true)
    end
  end
end
