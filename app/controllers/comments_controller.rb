class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :set_task
  before_action :set_comment, only: %i[edit update destroy]

  def create
    @comment = @task.comments.build(comment_params)
    @comment.user = current_user
    authorize @comment

    if @comment.save
      CommentNotificationJob.perform_later(@comment)
      redirect_to [ @project, @task ], notice: t("comments.create.success")
    else
      @comments = @task.comments.ordered
      render "tasks/show", status: :unprocessable_content
    end
  end

  def edit
    authorize @comment
  end

  def update
    authorize @comment
    if @comment.update(comment_params)
      redirect_to [ @project, @task ], notice: t("comments.update.success")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @comment
    @comment.destroy!
    redirect_to [ @project, @task ], notice: t("comments.destroy.success")
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.find(params[:task_id])
  end

  def set_comment
    @comment = @task.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
