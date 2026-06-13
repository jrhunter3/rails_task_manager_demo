class NotificationMailer < ApplicationMailer
  def comment_added(recipient, comment)
    @recipient = recipient
    @comment = comment
    @task = comment.commentable
    @project = @task.project
    @author = comment.user

    mail(to: recipient.email, subject: "New comment on #{@task.title}")
  end

  def task_updated(recipient, task)
    @recipient = recipient
    @task = task
    @project = task.project

    mail(to: recipient.email, subject: "Task updated: #{@task.title}")
  end
end
