class ApplicationController < ActionController::Base
  include Pundit::Authorization

  allow_browser versions: :modern
  stale_when_importmap_changes

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def not_found
    render "public/404", status: :not_found, layout: false
  end

  def user_not_authorized
    redirect_to root_path, alert: "You are not authorized to perform this action."
  end
end
