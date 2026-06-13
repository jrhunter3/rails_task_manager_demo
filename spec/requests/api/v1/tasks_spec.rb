require 'rails_helper'

RSpec.describe "Api::V1::Tasks", type: :request do
  let(:user) { create(:user) }
  let(:token) { user.raw_api_token }
  let(:headers) { { "Authorization" => "Bearer #{token}" } }
  let(:project) { create(:project) }

  before do
    create(:project_membership, user: user, project: project, role: :member)
  end

  describe "unauthenticated access" do
    it "returns unauthorized without a token" do
      get api_v1_project_tasks_path(project)
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns unauthorized with an invalid token" do
      get api_v1_project_tasks_path(project), headers: { "Authorization" => "Bearer invalid" }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "not found" do
    it "returns 404 for a non-existent project on index" do
      get api_v1_project_tasks_path(project_id: -1), headers: headers

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["errors"]).to eq([ "Not found" ])
    end

    it "returns 404 for a non-existent project on create" do
      post api_v1_project_tasks_path(project_id: -1), params: { task: { title: "Nope" } }, headers: headers

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["errors"]).to eq([ "Not found" ])
    end

    it "returns 404 for a non-existent project on update" do
      patch api_v1_project_task_path(project_id: -1, id: 1), params: { task: { title: "Nope" } }, headers: headers

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["errors"]).to eq([ "Not found" ])
    end

    it "returns 404 for a non-existent project on destroy" do
      delete api_v1_project_task_path(project_id: -1, id: 1), headers: headers

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["errors"]).to eq([ "Not found" ])
    end

    it "returns 404 for a non-existent task on show" do
      get api_v1_project_task_path(project, id: -1), headers: headers

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["errors"]).to eq([ "Not found" ])
    end

    it "returns 404 for a non-existent task on update" do
      patch api_v1_project_task_path(project, id: -1), params: { task: { title: "Nope" } }, headers: headers

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["errors"]).to eq([ "Not found" ])
    end

    it "returns 404 for a non-existent task on destroy" do
      delete api_v1_project_task_path(project, id: -1), headers: headers

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["errors"]).to eq([ "Not found" ])
    end
  end

  describe "GET /api/v1/projects/:project_id/tasks" do
    it "lists tasks for the project" do
      task = create(:task, project: project, title: "API task")
      create(:task, title: "Other task")

      get api_v1_project_tasks_path(project), headers: headers

      expect(response).to have_http_status(:success)
      body = response.parsed_body
      expect(body.length).to eq(1)
      expect(body[0]["title"]).to eq("API task")
    end
  end

  describe "GET /api/v1/projects/:project_id/tasks/:id" do
    it "shows the task" do
      task = create(:task, project: project)

      get api_v1_project_task_path(project, task), headers: headers

      expect(response).to have_http_status(:success)
      expect(response.parsed_body["title"]).to eq(task.title)
    end

    it "returns forbidden for a non-member" do
      other_project = create(:project)
      task = create(:task, project: other_project)

      get api_v1_project_task_path(other_project, task), headers: headers

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /api/v1/projects/:project_id/tasks" do
    it "creates a task" do
      expect do
        post api_v1_project_tasks_path(project), params: { task: { title: "API task", priority: "high" } }, headers: headers
      end.to change(Task, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body["title"]).to eq("API task")
    end

    it "returns unprocessable on validation failure" do
      post api_v1_project_tasks_path(project), params: { task: { title: "" } }, headers: headers

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to include("field" => "title", "error" => "is invalid")
    end

    it "returns forbidden for a non-member" do
      other_project = create(:project)

      post api_v1_project_tasks_path(other_project), params: { task: { title: "Hacked" } }, headers: headers

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /api/v1/projects/:project_id/tasks/:id" do
    it "updates the task" do
      task = create(:task, project: project)

      patch api_v1_project_task_path(project, task), params: { task: { title: "Updated" } }, headers: headers

      expect(response).to have_http_status(:success)
      expect(task.reload.title).to eq("Updated")
    end

    it "returns unprocessable on validation failure" do
      task = create(:task, project: project)

      patch api_v1_project_task_path(project, task), params: { task: { title: "" } }, headers: headers

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to include("field" => "title", "error" => "is invalid")
    end

    it "returns forbidden for a non-member" do
      other_project = create(:project)
      task = create(:task, project: other_project)

      patch api_v1_project_task_path(other_project, task), params: { task: { title: "Hacked" } }, headers: headers

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /api/v1/projects/:project_id/tasks/:id" do
    it "returns forbidden for a regular member" do
      task = create(:task, project: project)

      expect do
        delete api_v1_project_task_path(project, task), headers: headers
      end.not_to change(Task, :count)

      expect(response).to have_http_status(:forbidden)
    end

    it "destroys for a project admin" do
      admin = create(:user)
      create(:project_membership, user: admin, project: project, role: :admin)
      task = create(:task, project: project)

      expect do
        delete api_v1_project_task_path(project, task), headers: { "Authorization" => "Bearer #{admin.raw_api_token}" }
      end.to change(Task, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
