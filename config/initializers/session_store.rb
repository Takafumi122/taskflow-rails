Rails.application.config.session_store :cookie_store,
  key: "_taskflow_session", httponly: true, same_site: :lax,
  secure: Rails.env.production?, expire_after: 7.days
Rails.application.config.filter_parameters += [:demo_token, :token]
