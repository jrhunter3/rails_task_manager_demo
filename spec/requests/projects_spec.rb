require 'rails_helper'

RSpec.describe "Projects", type: :request do
  let(:user) { create(:user) }

  describe "unauthenticated access" do
    it "redirects to sign in" do
      get projects_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /projects" do
    it "lists projects the user belongs to" do
      project = create(:project)
      create(:project_membership, user: user, project: project)

      sign_in user
      get projects_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(project.name)
    end

    it "does not list projects the user does not belong to" do
      other_project = create(:project)

      sign_in user
      get projects_path

      expect(response.body).not_to include(other_project.name)
    end

    it "filters by search query" do
      matching = create(:project, name: "Alpha Project")
      other = create(:project, name: "Beta Project")
      create(:project_membership, user: user, project: matching)
      create(:project_membership, user: user, project: other)

      sign_in user
      get projects_path, params: { q: { name_or_description_cont: "Alpha" } }

      expect(response.body).to include("Alpha Project")
      expect(response.body).not_to include("Beta Project")
    end
  end

  describe "GET /projects/:id" do
    it "shows the project to a member" do
      project = create(:project)
      create(:project_membership, user: user, project: project)

      sign_in user
      get project_path(project)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(project.name)
    end

    it "redirects a non-member" do
      project = create(:project)

      sign_in user
      get project_path(project)

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to perform this action.")
    end

    it "returns 404 for a non-existent project" do
      sign_in user
      get project_path(id: -1)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /projects/new" do
    it "renders the form" do
      sign_in user
      get new_project_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("New Project")
    end
  end

  describe "GET /projects/:id/edit" do
    it "renders the form for an admin" do
      project = create(:project)
      create(:project_membership, user: user, project: project, role: :admin)

      sign_in user
      get edit_project_path(project)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Edit Project")
    end

    it "blocks edit for a regular member" do
      project = create(:project)
      create(:project_membership, user: user, project: project, role: :member)

      sign_in user
      get edit_project_path(project)

      expect(response).to redirect_to(root_path)
    end

    it "returns 404 for a non-existent project" do
      sign_in user
      get edit_project_path(id: -1)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /projects" do
    it "creates a project and adds the creator as admin" do
      sign_in user

      expect do
        post projects_path, params: { project: { name: "New Project", description: "Desc" } }
      end.to change(Project, :count).by(1)

      project = Project.last
      expect(project.owner).to eq(user)
      expect(project.project_memberships.find_by(user: user).role).to eq("admin")
      expect(response).to redirect_to(project_path(project))
    end

    it "renders new on validation failure" do
      sign_in user
      post projects_path, params: { project: { name: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /projects/:id" do
    it "updates the project for an admin member" do
      project = create(:project)
      create(:project_membership, user: user, project: project, role: :admin)

      sign_in user
      patch project_path(project), params: { project: { name: "Updated" } }

      expect(project.reload.name).to eq("Updated")
      expect(response).to redirect_to(project_path(project))
    end

    it "renders edit on validation failure" do
      project = create(:project)
      create(:project_membership, user: user, project: project, role: :admin)

      sign_in user
      patch project_path(project), params: { project: { name: "" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Edit Project")
    end

    it "blocks update for a regular member" do
      project = create(:project)
      create(:project_membership, user: user, project: project, role: :member)

      sign_in user
      patch project_path(project), params: { project: { name: "Hacked" } }

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to perform this action.")
    end

    it "returns 404 for a non-existent project" do
      sign_in user
      patch project_path(id: -1), params: { project: { name: "Nope" } }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /projects/:id" do
    it "destroys the project for an admin" do
      project = create(:project)
      create(:project_membership, user: user, project: project, role: :admin)

      sign_in user
      expect do
        delete project_path(project)
      end.to change(Project, :count).by(-1)

      expect(response).to redirect_to(projects_path)
    end

    it "blocks destroy for a regular member" do
      project = create(:project)
      create(:project_membership, user: user, project: project, role: :member)

      sign_in user
      expect do
        delete project_path(project)
      end.not_to change(Project, :count)

      expect(response).to redirect_to(root_path)
    end

    it "returns 404 for a non-existent project" do
      sign_in user
      delete project_path(id: -1)

      expect(response).to have_http_status(:not_found)
    end
  end
end
