require 'rails_helper'

RSpec.describe "Api::V1::ErrorRescue", type: :request do
  let(:user) { create(:user) }
  let(:token) { user.raw_api_token }
  let(:headers) { { "Authorization" => "Bearer #{token}" } }

  describe "StandardError rescue" do
    it "returns 500 for an internal error" do
      project = create(:project)
      create(:project_membership, user: user, project: project)

      allow_any_instance_of(Api::V1::ProjectsController).to receive(:index).and_raise("Unexpected boom")

      get api_v1_projects_path, headers: headers

      expect(response).to have_http_status(:internal_server_error)
      expect(response.parsed_body["errors"]).to eq([ "Internal server error" ])
    end
  end

  describe "ParseError rescue" do
    it "returns 400 for malformed JSON" do
      project = create(:project)
      create(:project_membership, user: user, project: project, role: :admin)

      patch api_v1_project_path(project),
           params: "{ bad json }",
           headers: headers.merge("Content-Type" => "application/json")

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body["errors"]).to eq([ "Bad request" ])
    end
  end

  describe "RecordNotUnique rescue" do
    it "returns 422 for a duplicate record" do
      project = create(:project)
      create(:project_membership, user: user, project: project, role: :admin)

      allow_any_instance_of(Api::V1::ProjectsController).to receive(:create).and_raise(ActiveRecord::RecordNotUnique.new("dup"))

      post api_v1_projects_path, params: { project: { name: "Test" } }, headers: headers

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to eq([ "Unprocessable" ])
    end
  end

  describe "RecordNotDestroyed rescue" do
    it "returns 422 when a record cannot be destroyed" do
      project = create(:project)
      create(:project_membership, user: user, project: project, role: :admin)

      allow_any_instance_of(Api::V1::ProjectsController).to receive(:destroy).and_raise(ActiveRecord::RecordNotDestroyed.new("nope"))

      delete api_v1_project_path(project), headers: headers

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to eq([ "Unprocessable" ])
    end
  end

  describe "InvalidForeignKey rescue" do
    it "returns 422 for a foreign key violation" do
      project = create(:project)
      create(:project_membership, user: user, project: project, role: :admin)

      allow_any_instance_of(Api::V1::ProjectsController).to receive(:destroy).and_raise(ActiveRecord::InvalidForeignKey.new("FK violation"))

      delete api_v1_project_path(project), headers: headers

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to eq([ "Unprocessable" ])
    end
  end

  describe "ParameterMissing rescue" do
    it "returns 422 for missing params" do
      post api_v1_projects_path, params: {}, headers: headers

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to eq([ "Unprocessable" ])
    end
  end
end
