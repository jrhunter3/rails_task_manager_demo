require 'rails_helper'

RSpec.describe Project, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'associations' do
    it 'belongs to an owner' do
      user = create(:user)
      project = create(:project, owner: user)
      expect(project.owner).to eq(user)
    end

    it 'has many members through memberships' do
      user = create(:user)
      project = create(:project)
      create(:project_membership, user: user, project: project)
      expect(project.members).to include(user)
    end
  end

  describe 'factories' do
    it 'creates a valid project' do
      expect { create(:project) }.to change(described_class, :count).by(1)
    end
  end
end
