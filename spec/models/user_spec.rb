require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:email) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:role).with_values(member: 0, admin: 1) }
  end

  describe 'associations' do
    it 'has many owned_projects' do
      user = create(:user)
      project = create(:project, owner: user)
      expect(user.owned_projects).to include(project)
    end

    it 'has many project_memberships' do
      user = create(:user)
      project = create(:project)
      membership = create(:project_membership, user: user, project: project)
      expect(user.project_memberships).to include(membership)
    end

    it 'has many projects through memberships' do
      user = create(:user)
      project = create(:project)
      create(:project_membership, user: user, project: project)
      expect(user.projects).to include(project)
    end
  end

  describe 'Devise modules' do
    it 'authenticates with valid credentials' do
      user = create(:user, password: 'secret123', password_confirmation: 'secret123')
      expect(user.valid_password?('secret123')).to be true
    end

    it 'rejects invalid credentials' do
      user = create(:user, password: 'secret123', password_confirmation: 'secret123')
      expect(user.valid_password?('wrong')).to be false
    end
  end

  describe 'factories' do
    it 'creates a valid user' do
      expect { create(:user) }.to change(described_class, :count).by(1)
    end

    it 'creates an admin user' do
      admin = create(:user, :admin)
      expect(admin).to be_admin
    end
  end
end
