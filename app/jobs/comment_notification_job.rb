class CommentNotificationJob < ApplicationJob
  queue_as :default

  def perform(comment)
    return unless comment.commentable.is_a?(Task)

    task = comment.commentable
    project = task.project
    recipients = project.members.where.not(id: comment.user_id)

    recipients.each do |recipient|
      NotificationMailer.comment_added(recipient, comment).deliver_now
    end
  end
end
