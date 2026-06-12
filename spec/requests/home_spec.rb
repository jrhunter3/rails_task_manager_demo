require 'rails_helper'

RSpec.describe "Homes", type: :request do
  describe "GET /" do
    it "redirects to sign in when not authenticated" do
      get root_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "returns success when authenticated" do
      user = create(:user)
      sign_in user
      get root_path
      expect(response).to have_http_status(:success)
    end
  end
end
