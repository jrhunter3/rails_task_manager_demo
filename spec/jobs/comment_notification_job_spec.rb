require 'rails_helper'

RSpec.describe CommentNotificationJob, type: :job do
  include ActiveJob::TestHelper

  describe '#perform' do
    let(:author) { create(:user) }
    let(:member) { create(:user) }
    let(:project) { create(:project, owner: member) }
    let(:task) { create(:task, project: project) }

    before do
      create(:project_membership, user: author, project: project)
    end

    it 'sends notification to all project members except the author' do
      comment = create(:comment, user: author, commentable: task)

      expect do
        perform_enqueued_jobs do
          described_class.perform_later(comment)
        end
      end.to change(ActionMailer::Base.deliveries, :count).by(1)

      delivery = ActionMailer::Base.deliveries.last
      expect(delivery.to).to eq([ member.email ])
    end

    it 'sends no email when the commentable is not a Task' do
      comment = create(:comment, commentable: create(:project))

      expect do
        perform_enqueued_jobs do
          described_class.perform_later(comment)
        end
      end.not_to change(ActionMailer::Base.deliveries, :count)
    end
  end
end
