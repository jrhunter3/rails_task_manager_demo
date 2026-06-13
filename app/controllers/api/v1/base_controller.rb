module Api
  module V1
    class BaseController < ActionController::API
      include Pundit::Authorization

      before_action :authenticate_api_user!

      rescue_from StandardError, with: :internal_server_error
      rescue_from ActionDispatch::Http::Parameters::ParseError, with: :bad_request
      rescue_from ActionController::ParameterMissing, with: :unprocessable
      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordNotUnique, with: :unprocessable
      rescue_from ActiveRecord::RecordNotDestroyed, with: :unprocessable
      rescue_from ActiveRecord::InvalidForeignKey, with: :unprocessable
      rescue_from Pundit::NotAuthorizedError, with: :forbidden

      after_action :verify_authorized, unless: -> { action_name == "index" }
      after_action :verify_policy_scoped, only: :index

      private

      def authenticate_api_user!
        token = request.headers["Authorization"]&.delete_prefix("Bearer ")
        digest = Digest::SHA256.hexdigest(token) if token
        @current_user = User.find_by(api_token: digest) if digest
        unless @current_user
          render json: { errors: [ I18n.t("api.unauthorized") ] }, status: :unauthorized
          nil
        end
      end

      def current_user
        @current_user
      end

      def not_found
        render json: { errors: [ I18n.t("api.not_found") ] }, status: :not_found
      end

      def forbidden
        render json: { errors: [ I18n.t("api.forbidden") ] }, status: :forbidden
      end

      def unprocessable
        render json: { errors: [ I18n.t("api.unprocessable") ] }, status: :unprocessable_content
      end

      def bad_request
        render json: { errors: [ I18n.t("api.bad_request") ] }, status: :bad_request
      end

      def internal_server_error
        render json: { errors: [ I18n.t("api.internal_server_error") ] }, status: :internal_server_error
      end

      def validation_errors(record)
        record.errors.map { |e| { field: e.attribute, error: "is invalid" } }
      end
    end
  end
end
