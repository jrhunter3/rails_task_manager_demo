require 'rails_helper'

RSpec.describe TaskPolicy do
  subject(:policy) { described_class.new(user, task) }

  let(:project) { create(:project) }
  let(:task) { create(:task, project: project) }

  describe "for a non-member" do
    let(:user) { create(:user) }

    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:transition) }
    it { is_expected.to forbid_action(:destroy) }
  end

  describe "for a member" do
    let(:user) { create(:user) }

    before do
      create(:project_membership, user: user, project: project, role: :member)
    end

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:transition) }
    it { is_expected.to forbid_action(:destroy) }
  end

  describe "for a project admin" do
    let(:user) { create(:user) }

    before do
      create(:project_membership, user: user, project: project, role: :admin)
    end

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:transition) }
    it { is_expected.to permit_action(:destroy) }
  end

  describe "for a site admin" do
    let(:user) { create(:user, :admin) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:transition) }
    it { is_expected.to permit_action(:destroy) }
  end

  describe "Scope" do
    it "includes tasks in projects the user belongs to" do
      user = create(:user)
      member_project = create(:project)
      create(:project_membership, user: user, project: member_project)
      member_task = create(:task, project: member_project)
      other_task = create(:task)

      scope = described_class::Scope.new(user, Task.all).resolve
      expect(scope).to include(member_task)
      expect(scope).not_to include(other_task)
    end

    it "includes all tasks for a site admin" do
      admin = create(:user, :admin)
      task1 = create(:task)
      task2 = create(:task)

      scope = described_class::Scope.new(admin, Task.all).resolve
      expect(scope).to include(task1)
      expect(scope).to include(task2)
    end

    it "includes no tasks for a non-member" do
      non_member = create(:user)
      create(:task)

      scope = described_class::Scope.new(non_member, Task.all).resolve
      expect(scope).to be_empty
    end
  end
end
