class TaskStateChangeJob < ApplicationJob
  queue_as :default

  def perform(task)
    project = task.project
    recipients = project.members

    recipients.each do |recipient|
      NotificationMailer.task_updated(recipient, task).deliver_now
    end
  end
end
