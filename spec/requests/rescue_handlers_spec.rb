require 'rails_helper'

RSpec.describe "RescueHandlers", type: :request do
  let(:user) { create(:user) }
  let(:project) { create(:project) }

  before do
    create(:project_membership, user: user, project: project, role: :admin)
    sign_in user
  end

  describe "RecordNotUnique rescue" do
    it "redirects on web with an alert" do
      allow_any_instance_of(ProjectsController).to receive(:create).and_raise(ActiveRecord::RecordNotUnique.new("dup"))

      post projects_path, params: { project: { name: "Test" } }

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Something went wrong. Please try again.")
    end
  end

  describe "RecordNotDestroyed rescue" do
    it "redirects on web with an alert" do
      allow_any_instance_of(ProjectsController).to receive(:destroy).and_raise(ActiveRecord::RecordNotDestroyed.new("nope"))

      delete project_path(project)

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Something went wrong. Please try again.")
    end
  end

  describe "InvalidForeignKey rescue" do
    it "redirects on web with an alert" do
      allow_any_instance_of(ProjectsController).to receive(:destroy).and_raise(ActiveRecord::InvalidForeignKey.new("FK"))

      delete project_path(project)

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Something went wrong. Please try again.")
    end
  end

  describe "AASM::InvalidTransition rescue" do
    it "redirects on web with unauthorized alert" do
      task = create(:task, project: project)
      allow_any_instance_of(TasksController).to receive(:transition).and_raise(AASM::InvalidTransition.new(task, :complete, :default))

      post transition_project_task_path(project, task, event: "complete")

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to perform this action.")
    end
  end

  describe "ParameterMissing rescue" do
    it "redirects on web with an alert when params are missing" do
      patch project_path(project)

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Something went wrong. Please try again.")
    end
  end
end
