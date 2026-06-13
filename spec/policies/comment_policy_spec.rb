require 'rails_helper'

RSpec.describe CommentPolicy do
  subject(:policy) { described_class.new(user, comment) }

  let(:project) { create(:project) }
  let(:task) { create(:task, project: project) }
  let(:comment) { create(:comment, commentable: task) }

  describe "for a non-member" do
    let(:user) { create(:user) }

    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  describe "for a member who is not the author" do
    let(:user) { create(:user) }

    before do
      create(:project_membership, user: user, project: project, role: :member)
    end

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  describe "for the comment author" do
    let(:comment_author) { create(:user) }
    let(:user) { comment_author }
    let(:comment) { create(:comment, user: comment_author, commentable: task) }

    before do
      create(:project_membership, user: comment_author, project: project, role: :member)
    end

    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
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
    it { is_expected.to permit_action(:destroy) }
  end

  describe "for a site admin" do
    let(:user) { create(:user, :admin) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  describe "Scope" do
    it "includes comments on tasks in projects the user belongs to" do
      user = create(:user)
      member_project = create(:project)
      create(:project_membership, user: user, project: member_project)
      member_task = create(:task, project: member_project)
      member_comment = create(:comment, commentable: member_task)
      other_comment = create(:comment)

      scope = described_class::Scope.new(user, Comment.all).resolve
      expect(scope).to include(member_comment)
      expect(scope).not_to include(other_comment)
    end

    it "includes all comments for a site admin" do
      admin = create(:user, :admin)
      comment1 = create(:comment)
      comment2 = create(:comment)

      scope = described_class::Scope.new(admin, Comment.all).resolve
      expect(scope).to include(comment1)
      expect(scope).to include(comment2)
    end

    it "includes no comments for a non-member" do
      non_member = create(:user)
      create(:comment)

      scope = described_class::Scope.new(non_member, Comment.all).resolve
      expect(scope).to be_empty
    end
  end
end
