opts = { scope: 'user:email', provider_ignores_state: true}
opts = { provider_ignores_state: true}

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['CLIENT_ID'], ENV['CLIENT_SECRET'], opts
end

OmniAuth.config.logger = Rails.logger
