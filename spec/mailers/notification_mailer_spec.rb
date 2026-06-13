require 'rails_helper'

RSpec.describe NotificationMailer, type: :mailer do
  describe '#comment_added' do
    let(:project) { create(:project) }
    let(:task) { create(:task, project: project) }
    let(:author) { create(:user) }
    let(:recipient) { create(:user) }
    let(:comment) { create(:comment, user: author, commentable: task) }
    let(:mail) { described_class.comment_added(recipient, comment) }

    before do
      create(:project_membership, user: author, project: project)
      create(:project_membership, user: recipient, project: project)
    end

    it 'renders the headers' do
      expect(mail.subject).to eq("New comment on #{task.title}")
      expect(mail.to).to eq([ recipient.email ])
      expect(mail.from).to eq([ 'noreply@taskmanager.demo' ])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include(author.email)
      expect(mail.body.encoded).to include(task.title)
    end
  end

  describe '#task_updated' do
    let(:project) { create(:project) }
    let(:task) { create(:task, project: project) }
    let(:recipient) { create(:user) }
    let(:mail) { described_class.task_updated(recipient, task) }

    before do
      create(:project_membership, user: recipient, project: project)
    end

    it 'renders the headers' do
      expect(mail.subject).to eq("Task updated: #{task.title}")
      expect(mail.to).to eq([ recipient.email ])
      expect(mail.from).to eq([ 'noreply@taskmanager.demo' ])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include(task.title)
      expect(mail.body.encoded).to include(task.status)
    end
  end
end
