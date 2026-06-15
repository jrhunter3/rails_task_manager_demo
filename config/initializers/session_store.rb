Rails.application.config.session_store :cookie_store, key: "_task_manager_session",
  secure: ENV.fetch("FORCE_SSL", "true") == "true",
  httponly: true,
  same_site: :lax
