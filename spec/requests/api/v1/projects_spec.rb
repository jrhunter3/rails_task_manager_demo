require 'rails_helper'

RSpec.describe "Api::V1::Projects", type: :request do
  let(:user) { create(:user) }
  let(:token) { user.raw_api_token }
  let(:headers) { { "Authorization" => "Bearer #{token}" } }

  describe "unauthenticated access" do
    it "returns unauthorized without a token" do
      get api_v1_projects_path
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns unauthorized with an invalid token" do
      get api_v1_projects_path, headers: { "Authorization" => "Bearer invalid" }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/projects" do
    it "lists projects the user belongs to" do
      project = create(:project)
      create(:project_membership, user: user, project: project)

      get api_v1_projects_path, headers: headers

      expect(response).to have_http_status(:success)
      body = response.parsed_body
      expect(body.length).to eq(1)
      expect(body[0]["name"]).to eq(project.name)
    end

    it "does not list other projects" do
      create(:project)

      get api_v1_projects_path, headers: headers

      expect(response.parsed_body).to be_empty
    end
  end

  describe "GET /api/v1/projects/:id" do
    it "shows the project to a member" do
      project = create(:project)
      create(:project_membership, user: user, project: project)

      get api_v1_project_path(project), headers: headers

      expect(response).to have_http_status(:success)
      expect(response.parsed_body["name"]).to eq(project.name)
    end

    it "returns forbidden for a non-member" do
      project = create(:project)

      get api_v1_project_path(project), headers: headers

      expect(response).to have_http_status(:forbidden)
    end

    it "returns 404 for a non-existent project" do
      get api_v1_project_path(id: -1), headers: headers

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["errors"]).to eq([ "Not found" ])
    end
  end

  describe "POST /api/v1/projects" do
    it "creates a project" do
      expect do
        post api_v1_projects_path, params: { project: { name: "API Project", description: "Created via API" } }, headers: headers
      end.to change(Project, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body["name"]).to eq("API Project")
    end

    it "returns errors on validation failure" do
      post api_v1_projects_path, params: { project: { name: "" } }, headers: headers

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to be_an(Array)
    end
  end

  describe "PATCH /api/v1/projects/:id" do
    it "updates the project for an admin" do
      project = create(:project)
      create(:project_membership, user: user, project: project, role: :admin)

      patch api_v1_project_path(project), params: { project: { name: "Updated" } }, headers: headers

      expect(response).to have_http_status(:success)
      expect(project.reload.name).to eq("Updated")
    end

    it "returns validation errors on update" do
      project = create(:project)
      create(:project_membership, user: user, project: project, role: :admin)

      patch api_v1_project_path(project), params: { project: { name: "" } }, headers: headers

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to be_an(Array)
    end

    it "returns forbidden for a regular member" do
      project = create(:project)
      create(:project_membership, user: user, project: project, role: :member)

      patch api_v1_project_path(project), params: { project: { name: "Hacked" } }, headers: headers

      expect(response).to have_http_status(:forbidden)
    end

    it "returns 404 for a non-existent project" do
      patch api_v1_project_path(id: -1), params: { project: { name: "Nope" } }, headers: headers

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["errors"]).to eq([ "Not found" ])
    end
  end

  describe "DELETE /api/v1/projects/:id" do
    it "destroys the project for an admin" do
      project = create(:project)
      create(:project_membership, user: user, project: project, role: :admin)

      expect do
        delete api_v1_project_path(project), headers: headers
      end.to change(Project, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "returns forbidden for a regular member" do
      project = create(:project)
      create(:project_membership, user: user, project: project, role: :member)

      delete api_v1_project_path(project), headers: headers

      expect(response).to have_http_status(:forbidden)
    end

    it "returns 404 for a non-existent project" do
      delete api_v1_project_path(id: -1), headers: headers

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["errors"]).to eq([ "Not found" ])
    end
  end
end
