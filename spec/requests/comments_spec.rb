require 'rails_helper'

RSpec.describe "Comments", type: :request do
  let(:user) { create(:user) }
  let(:project) { create(:project) }
  let(:task) { create(:task, project: project) }

  before do
    create(:project_membership, user: user, project: project, role: :member)
  end

  describe "unauthenticated access" do
    it "redirects to sign in" do
      post project_task_comments_path(project, task)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "not found" do
    it "returns 404 for a non-existent project on create" do
      sign_in user
      post project_task_comments_path(project_id: -1, task_id: task), params: { comment: { content: "test" } }

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for a non-existent task on create" do
      sign_in user
      post project_task_comments_path(project, task_id: -1), params: { comment: { content: "test" } }

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for a non-existent project on edit" do
      sign_in user
      get edit_project_task_comment_path(project_id: -1, task_id: task, id: 1)

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for a non-existent project on update" do
      sign_in user
      patch project_task_comment_path(project_id: -1, task_id: task, id: 1), params: { comment: { content: "test" } }

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for a non-existent project on delete" do
      sign_in user
      delete project_task_comment_path(project_id: -1, task_id: task, id: 1)

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for a non-existent comment on update" do
      sign_in user
      patch project_task_comment_path(project, task, id: -1), params: { comment: { content: "test" } }

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for a non-existent comment on delete" do
      sign_in user
      delete project_task_comment_path(project, task, id: -1)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /projects/:project_id/tasks/:task_id/comments" do
    it "creates a comment" do
      sign_in user

      expect do
        post project_task_comments_path(project, task), params: { comment: { content: "Nice work!" } }
      end.to change(Comment, :count).by(1)

      expect(response).to redirect_to([ project, task ])
    end

    it "renders task show on validation failure" do
      sign_in user
      post project_task_comments_path(project, task), params: { comment: { content: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "redirects a non-member" do
      other_project = create(:project)
      other_task = create(:task, project: other_project)
      sign_in user
      post project_task_comments_path(other_project, other_task), params: { comment: { content: "Spam!" } }
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /projects/:project_id/tasks/:task_id/comments/:id/edit" do
    it "renders the form for the author" do
      sign_in user
      comment = create(:comment, user: user, commentable: task)
      get edit_project_task_comment_path(project, task, comment)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Edit Comment")
    end

    it "blocks a non-author" do
      other_user = create(:user)
      create(:project_membership, user: other_user, project: project, role: :member)
      comment = create(:comment, user: other_user, commentable: task)

      sign_in user
      get edit_project_task_comment_path(project, task, comment)

      expect(response).to redirect_to(root_path)
    end

    it "returns 404 for a non-existent comment" do
      sign_in user
      get edit_project_task_comment_path(project, task, id: -1)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /projects/:project_id/tasks/:task_id/comments/:id" do
    it "allows the author to update" do
      sign_in user
      comment = create(:comment, user: user, commentable: task)

      patch project_task_comment_path(project, task, comment), params: { comment: { content: "Updated!" } }

      expect(comment.reload.content.body.to_plain_text.strip).to eq("Updated!")
      expect(response).to redirect_to([ project, task ])
    end

    it "renders edit on validation failure" do
      sign_in user
      comment = create(:comment, user: user, commentable: task)
      patch project_task_comment_path(project, task, comment), params: { comment: { content: "" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Edit Comment")
    end

    it "blocks a non-author" do
      other_user = create(:user)
      create(:project_membership, user: other_user, project: project, role: :member)
      comment = create(:comment, user: other_user, commentable: task)

      sign_in user
      patch project_task_comment_path(project, task, comment), params: { comment: { content: "Hacked!" } }

      expect(response).to redirect_to(root_path)
    end
  end

  describe "DELETE /projects/:project_id/tasks/:task_id/comments/:id" do
    it "allows the author to delete" do
      sign_in user
      comment = create(:comment, user: user, commentable: task)

      expect do
        delete project_task_comment_path(project, task, comment)
      end.to change(Comment, :count).by(-1)

      expect(response).to redirect_to([ project, task ])
    end

    it "blocks a non-author" do
      other_user = create(:user)
      create(:project_membership, user: other_user, project: project, role: :member)
      comment = create(:comment, user: other_user, commentable: task)

      sign_in user
      expect do
        delete project_task_comment_path(project, task, comment)
      end.not_to change(Comment, :count)

      expect(response).to redirect_to(root_path)
    end

    it "allows a project admin to delete any comment" do
      admin = create(:user)
      create(:project_membership, user: admin, project: project, role: :admin)
      comment = create(:comment, user: user, commentable: task)

      sign_in admin
      expect do
        delete project_task_comment_path(project, task, comment)
      end.to change(Comment, :count).by(-1)

      expect(response).to redirect_to([ project, task ])
    end
  end
end
