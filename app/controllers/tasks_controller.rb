class TasksController < ApplicationController
  include SetProject

  before_action :authenticate_user!
  before_action :set_task, only: %i[show edit update destroy transition]

  def index
    @q = policy_scope(Task).where(project: @project).ransack(params[:q])
    @pagy, @tasks = pagy(@q.result.order(created_at: :desc))
  end

  def show
    authorize @task
    @comments = @task.comments.ordered.includes(:user)
  end

  def new
    @task = @project.tasks.build
    authorize @task
  end

  def edit
    authorize @task
  end

  def create
    @task = @project.tasks.build(task_params)
    authorize @task

    if @task.save
      redirect_to [ @project, @task ], notice: t("tasks.create.success")
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    authorize @task
    if @task.update(task_params)
      TaskStateChangeJob.perform_later(@task)
      redirect_to [ @project, @task ], notice: t("tasks.update.success")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @task
    @task.destroy!
    redirect_to project_tasks_path(@project), notice: t("tasks.destroy.success")
  end

  def transition
    authorize @task
    event = params[:event].to_sym
    if @task.aasm.events(permitted: true).map(&:name).include?(event)
      @task.public_send("#{event}!")
      TaskStateChangeJob.perform_later(@task)
      redirect_to [ @project, @task ], notice: t("tasks.transition.success", status: @task.status.humanize)
    else
      redirect_to [ @project, @task ], alert: t("tasks.transition.failure")
    end
  end

  private

  def set_task
    @task = @project.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :priority, :due_date, files: [])
  end
end
