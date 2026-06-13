require 'rails_helper'

RSpec.describe ProjectPolicy do
  subject(:policy) { described_class.new(user, project) }

  let(:project) { create(:project) }

  describe "for a non-member" do
    let(:user) { create(:user) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  describe "for a member" do
    let(:user) { create(:user) }

    before do
      create(:project_membership, user: user, project: project, role: :member)
    end

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  describe "for a project admin" do
    let(:user) { create(:user) }

    before do
      create(:project_membership, user: user, project: project, role: :admin)
    end

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  describe "for a site admin" do
    let(:user) { create(:user, :admin) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  describe "Scope" do
    it "includes projects the user belongs to" do
      user = create(:user)
      member_project = create(:project)
      create(:project_membership, user: user, project: member_project)
      other_project = create(:project)

      scope = described_class::Scope.new(user, Project.all).resolve
      expect(scope).to include(member_project)
      expect(scope).not_to include(other_project)
    end

    it "includes all projects for a site admin" do
      admin = create(:user, :admin)
      project1 = create(:project)
      project2 = create(:project)

      scope = described_class::Scope.new(admin, Project.all).resolve
      expect(scope).to include(project1)
      expect(scope).to include(project2)
    end

    it "includes no projects for a non-member" do
      non_member = create(:user)
      create(:project)

      scope = described_class::Scope.new(non_member, Project.all).resolve
      expect(scope).to be_empty
    end
  end
end
