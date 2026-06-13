module Api
  module V1
    class ProjectsController < BaseController
      def index
        @projects = policy_scope(Project)
        render json: @projects.map { |p| serialize_project(p) }
      end

      def show
        @project = Project.find(params[:id])
        authorize @project
        render json: serialize_project(@project)
      end

      def create
        @project = Project.new(project_params)
        @project.owner = current_user
        authorize @project

        if @project.save
          render json: serialize_project(@project), status: :created
        else
          render json: { errors: validation_errors(@project) }, status: :unprocessable_content
        end
      end

      def update
        @project = Project.find(params[:id])
        authorize @project

        if @project.update(project_params)
          render json: serialize_project(@project)
        else
          render json: { errors: validation_errors(@project) }, status: :unprocessable_content
        end
      end

      def destroy
        @project = Project.find(params[:id])
        authorize @project
        @project.destroy!
        head :no_content
      end

      private

      def project_params
        params.require(:project).permit(:name, :description)
      end

      def serialize_project(project)
        {
          id: project.id,
          name: project.name,
          description: project.description,
          owner_email: project.owner.email,
          created_at: project.created_at,
          updated_at: project.updated_at
        }
      end
    end
  end
end
