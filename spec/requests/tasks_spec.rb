require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  let(:user) { create(:user) }
  let(:project) { create(:project) }

  before do
    create(:project_membership, user: user, project: project, role: :member)
  end

  describe "unauthenticated access" do
    it "redirects to sign in" do
      get project_tasks_path(project)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "not found" do
    it "returns 404 for a non-existent project on index" do
      sign_in user
      get project_tasks_path(project_id: -1)

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for a non-existent project on create" do
      sign_in user
      post project_tasks_path(project_id: -1), params: { task: { title: "Nope" } }

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for a non-existent task on show" do
      sign_in user
      get project_task_path(project, id: -1)

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for a non-existent task on update" do
      sign_in user
      patch project_task_path(project, id: -1), params: { task: { title: "Nope" } }

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for a non-existent task on delete" do
      sign_in user
      delete project_task_path(project, id: -1)

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for a non-existent project on transition" do
      sign_in user
      post transition_project_task_path(project_id: -1, id: 1, event: "start")

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /projects/:project_id/tasks" do
    it "lists tasks for the project" do
      task = create(:task, project: project, title: "Visible task")
      other_task = create(:task, title: "Other project task")

      sign_in user
      get project_tasks_path(project)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Visible task")
      expect(response.body).not_to include("Other project task")
    end

    it "filters by title search" do
      matching = create(:task, project: project, title: "Bug fix")
      other = create(:task, project: project, title: "Feature request")

      sign_in user
      get project_tasks_path(project), params: { q: { title_or_description_cont: "Bug" } }

      expect(response.body).to include("Bug fix")
      expect(response.body).not_to include("Feature request")
    end

    it "filters by status" do
      backlog_task = create(:task, project: project, title: "Backlog task")
      done_task = create(:task, project: project, title: "Done task")
      done_task.update!(status: :done)

      sign_in user
      get project_tasks_path(project), params: { q: { status_eq: "done" } }

      expect(response.body).to include("Done task")
      expect(response.body).not_to include("Backlog task")
    end

    it "filters by priority" do
      high_task = create(:task, project: project, title: "High task", priority: :high)
      low_task = create(:task, project: project, title: "Low task", priority: :low)

      sign_in user
      get project_tasks_path(project), params: { q: { priority_eq: Task.priorities[:high] } }

      expect(response.body).to include("High task")
      expect(response.body).not_to include("Low task")
    end
  end

  describe "GET /projects/:project_id/tasks/new" do
    it "renders the form" do
      sign_in user
      get new_project_task_path(project)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("New Task")
    end
  end

  describe "POST /projects/:project_id/tasks" do
    it "creates a task with file attachments" do
      sign_in user
      file = Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/test.txt"), "text/plain")

      expect do
        post project_tasks_path(project), params: { task: { title: "File task", files: [ file ] } }
      end.to change(Task, :count).by(1)

      expect(Task.last.files).to be_attached
    end
    it "creates a task" do
      sign_in user

      expect do
        post project_tasks_path(project), params: { task: { title: "New task", priority: :high } }
      end.to change(Task, :count).by(1)

      expect(response).to redirect_to(project_task_path(project, Task.last))
    end

    it "renders new on validation failure" do
      sign_in user
      post project_tasks_path(project), params: { task: { title: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "redirects a non-member" do
      other_project = create(:project)
      sign_in user
      post project_tasks_path(other_project), params: { task: { title: "Should not create" } }
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /projects/:project_id/tasks/:id/edit" do
    it "renders the form" do
      task = create(:task, project: project)
      sign_in user
      get edit_project_task_path(project, task)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Edit Task")
    end

    it "redirects a non-member" do
      other_project = create(:project)
      task = create(:task, project: other_project)
      sign_in user
      get edit_project_task_path(other_project, task)
      expect(response).to redirect_to(root_path)
    end

    it "returns 404 for a non-existent task" do
      sign_in user
      get edit_project_task_path(project, id: -1)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /projects/:project_id/tasks/:id" do
    it "shows the task to a member" do
      task = create(:task, project: project)
      sign_in user
      get project_task_path(project, task)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(task.title)
    end

    it "redirects a non-member" do
      other_project = create(:project)
      task = create(:task, project: other_project)

      sign_in user
      get project_task_path(other_project, task)

      expect(response).to redirect_to(root_path)
    end
  end

  describe "PATCH /projects/:project_id/tasks/:id" do
    it "updates the task" do
      task = create(:task, project: project)
      sign_in user

      patch project_task_path(project, task), params: { task: { title: "Updated" } }

      expect(task.reload.title).to eq("Updated")
      expect(response).to redirect_to(project_task_path(project, task))
    end

    it "attaches files" do
      task = create(:task, project: project)
      sign_in user
      file = Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/test.txt"), "text/plain")

      patch project_task_path(project, task), params: { task: { files: [ file ] } }

      expect(task.reload.files).to be_attached
    end

    it "renders edit on validation failure" do
      task = create(:task, project: project)
      sign_in user
      patch project_task_path(project, task), params: { task: { title: "" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Edit Task")
    end

    it "redirects a non-member" do
      other_project = create(:project)
      task = create(:task, project: other_project)
      sign_in user
      patch project_task_path(other_project, task), params: { task: { title: "Hacked" } }
      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /projects/:project_id/tasks/:id/transition" do
    it "triggers a valid state transition" do
      task = create(:task, project: project)
      sign_in user

      post transition_project_task_path(project, task, event: "start")

      expect(task.reload).to be_in_progress
      expect(response).to redirect_to(project_task_path(project, task))
    end

    it "rejects an invalid transition" do
      task = create(:task, project: project)
      sign_in user

      post transition_project_task_path(project, task, event: "complete")

      expect(task.reload).to be_backlog
      expect(response).to redirect_to(project_task_path(project, task))
    end

    it "redirects a non-member" do
      other_project = create(:project)
      task = create(:task, project: other_project)
      sign_in user
      post transition_project_task_path(other_project, task, event: "start")
      expect(response).to redirect_to(root_path)
    end
  end

  describe "DELETE /projects/:project_id/tasks/:id" do
    it "blocks destroy for a regular member" do
      task = create(:task, project: project)
      sign_in user

      expect do
        delete project_task_path(project, task)
      end.not_to change(Task, :count)

      expect(response).to redirect_to(root_path)
    end

    it "allows destroy for a project admin" do
      admin = create(:user)
      create(:project_membership, user: admin, project: project, role: :admin)
      task = create(:task, project: project)

      sign_in admin
      expect do
        delete project_task_path(project, task)
      end.to change(Task, :count).by(-1)

      expect(response).to redirect_to(project_tasks_path(project))
    end
  end
end
