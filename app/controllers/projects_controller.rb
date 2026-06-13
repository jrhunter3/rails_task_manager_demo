class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: %i[show edit update destroy]

  def index
    @q = policy_scope(Project).ransack(params[:q])
    @pagy, @projects = pagy(@q.result.includes(:owner))
  end

  def show
    authorize @project
  end

  def new
    @project = Project.new
    authorize @project
  end

  def edit
    authorize @project
  end

  def create
    @project = Project.new(project_params)
    @project.owner = current_user
    authorize @project

    if @project.save
      redirect_to @project, notice: t("projects.create.success")
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    authorize @project
    if @project.update(project_params)
      redirect_to @project, notice: t("projects.update.success")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @project
    @project.destroy!
    redirect_to projects_path, notice: t("projects.destroy.success")
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description)
  end
end
