class Rack::Attack
  throttle("sign-in by IP", limit: 10, period: 1.minute) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.ip
    end
  end

  throttle("API by IP", limit: 60, period: 1.minute) do |req|
    if req.path.start_with?("/api/")
      req.ip
    end
  end
end

Rack::Attack.enabled = !Rails.env.test?
