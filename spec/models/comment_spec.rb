require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:content) }

    it 'rejects content with only whitespace or empty HTML' do
      comment = build(:comment)
      comment.content = "<div></div>"
      comment.validate
      expect(comment.errors[:content]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:commentable) }
  end

  describe 'factories' do
    it 'creates a valid comment' do
      expect { create(:comment) }.to change(described_class, :count).by(1)
    end
  end
end
