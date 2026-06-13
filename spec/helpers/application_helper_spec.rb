require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#task_state_events' do
    it 'returns permitted events for a task' do
      task = create(:task)
      events = helper.task_state_events(task)
      names = events.map(&:name)
      expect(names).to include(:start)
      expect(names).not_to include(:complete)
    end

    it 'returns only reopen when task is done' do
      task = create(:task, status: :done)
      task.update!(status: :done)
      events = helper.task_state_events(task)
      expect(events.map(&:name)).to contain_exactly(:reopen)
    end
  end
end
