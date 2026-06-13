require 'rails_helper'

RSpec.describe TaskStateChangeJob, type: :job do
  include ActiveJob::TestHelper

  describe '#perform' do
    let(:member1) { create(:user) }
    let(:member2) { create(:user) }
    let(:project) { create(:project, owner: member1) }
    let(:task) { create(:task, project: project) }

    before do
      create(:project_membership, user: member2, project: project)
    end

    it 'sends notification to all project members' do
      expect do
        perform_enqueued_jobs do
          described_class.perform_later(task)
        end
      end.to change(ActionMailer::Base.deliveries, :count).by(2)
    end
  end
end
