module Api
  module V1
    class TasksController < BaseController
      include SetProject

      def index
        @tasks = policy_scope(Task).where(project: @project)
        render json: @tasks.map { |t| serialize_task(t) }
      end

      def show
        @task = @project.tasks.find(params[:id])
        authorize @task
        render json: serialize_task(@task)
      end

      def create
        @task = @project.tasks.build(task_params)
        authorize @task

        if @task.save
          render json: serialize_task(@task), status: :created
        else
          render json: { errors: validation_errors(@task) }, status: :unprocessable_content
        end
      end

      def update
        @task = @project.tasks.find(params[:id])
        authorize @task

        if @task.update(task_params)
          render json: serialize_task(@task)
        else
          render json: { errors: validation_errors(@task) }, status: :unprocessable_content
        end
      end

      def destroy
        @task = @project.tasks.find(params[:id])
        authorize @task
        @task.destroy!
        head :no_content
      end

      private

      def task_params
        params.require(:task).permit(:title, :description, :priority, :due_date, files: [])
      end

      def serialize_task(task)
        {
          id: task.id,
          title: task.title,
          description: task.description,
          status: task.status,
          priority: task.priority,
          due_date: task.due_date,
          created_at: task.created_at,
          updated_at: task.updated_at
        }
      end
    end
  end
end
