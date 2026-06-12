require 'rails_helper'

RSpec.describe ProjectMembership, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:role) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:role).with_values(member: 0, admin: 1) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:project) }
  end

  describe 'uniqueness' do
    it 'prevents duplicate membership for same user and project' do
      user = create(:user)
      project = create(:project)
      create(:project_membership, user: user, project: project)
      duplicate = build(:project_membership, user: user, project: project)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("has already been taken")
    end
  end
end
