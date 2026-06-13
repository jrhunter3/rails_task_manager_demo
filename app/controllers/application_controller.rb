class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Pagy::Backend

  allow_browser versions: :modern
  stale_when_importmap_changes

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordNotUnique, with: :unprocessable
  rescue_from ActiveRecord::RecordNotDestroyed, with: :unprocessable
  rescue_from ActiveRecord::InvalidForeignKey, with: :unprocessable
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable
  rescue_from AASM::InvalidTransition, with: :user_not_authorized
  rescue_from ActionController::ParameterMissing, with: :unprocessable
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  after_action :verify_authorized, unless: -> { devise_controller? || action_name == "index" }
  after_action :verify_policy_scoped, if: -> { action_name == "index" && !devise_controller? }

  private

  def not_found
    render file: Rails.public_path.join("404.html"), status: :not_found, layout: false
  end

  def user_not_authorized
    redirect_to root_path, alert: t("unauthorized.default")
  end

  def unprocessable
    redirect_back fallback_location: root_path, alert: t("unprocessable.default")
  end
end
