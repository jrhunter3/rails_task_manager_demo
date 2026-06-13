require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
    it { is_expected.to have_many_attached(:files) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:priority).with_values(low: 0, medium: 1, high: 2) }
  end

  describe 'state machine' do
    let(:task) { create(:task) }

    it 'starts as backlog' do
      expect(task).to be_backlog
    end

    it 'transitions backlog -> in_progress' do
      task.start!
      expect(task).to be_in_progress
    end

    it 'transitions in_progress -> review' do
      task.start!
      task.submit_for_review!
      expect(task).to be_review
    end

    it 'transitions review -> in_progress (request changes)' do
      task.start!
      task.submit_for_review!
      task.request_changes!
      expect(task).to be_in_progress
    end

    it 'transitions review -> done' do
      task.start!
      task.submit_for_review!
      task.complete!
      expect(task).to be_done
    end

    it 'transitions done -> in_progress (reopen)' do
      task.update!(status: :done)
      task.reopen!
      expect(task).to be_in_progress
    end

    it 'prevents invalid transition' do
      expect { task.complete! }.to raise_error(AASM::InvalidTransition)
    end
  end

  describe 'scopes' do
    it 'orders by newest first' do
      old = create(:task, created_at: 1.day.ago)
      new = create(:task, created_at: Time.current)
      expect(Task.ordered).to eq([ new, old ])
    end
  end

  describe 'file validations' do
    let(:task) { create(:task) }

    it 'rejects files with invalid content type' do
      task.files.attach(io: StringIO.new("not an image"), filename: "test.exe", content_type: "application/x-msdownload")
      task.validate
      expect(task.errors[:files]).to be_present
    end

    it 'accepts files with valid content type' do
      task.files.attach(io: StringIO.new("plain text"), filename: "test.txt", content_type: "text/plain")
      task.validate
      expect(task.errors[:files]).to be_empty
    end

    it 'rejects files exceeding 10MB' do
      oversized = StringIO.new("x" * (11 * 1024 * 1024))
      task.files.attach(io: oversized, filename: "big.txt", content_type: "text/plain")
      task.validate
      expect(task.errors[:files]).to be_present
      expect(task.errors[:files].first).to include("10MB")
    end
  end

  describe 'factories' do
    it 'creates a valid task' do
      expect { create(:task) }.to change(described_class, :count).by(1)
    end
  end
end
