class Api::TasksController < ApplicationController
    before_action :set_task, only: [ :show, :update, :destroy ]

    def index
        tasks = Task.all

        if params[:status].present?
            return render_bad_request("Invalid status") unless Task.statuses.key?(params[:status])

            tasks = tasks.with_status(params[:status])
        end

        if params[:sort_by].present? || params[:order].present?
            sort_by = params[:sort_by].presence || "due_date"
            order = params[:order].presence || "asc"

            return render_bad_request("Invalid sort_by") unless sort_by == "due_date"
            return render_bad_request("Invalid order") unless %w[asc desc].include?(order)

            tasks = tasks.order_by_due_date(order)
        else
            tasks = tasks.recent
        end

        pagination = paginator.paginate(tasks)

        return render_bad_request(pagination.error_message) unless pagination.success?

        render json: {
            data: pagination.records,
            meta: pagination.meta
        }
    end

    def show
        render json: @task
    end

    def create
        task = Task.new(task_params)

        if task.save
            render json: task, status: :created
        else
            render_validation_errors(task)
        end
    end

    def update
        if @task.update(task_params)
            render json: @task
        else
            render_validation_errors(@task)
        end
    end

    def destroy
        @task.destroy

        head :no_content
    end

    private

    def set_task
        @task = Task.find(params[:id])
    end

    def task_params
        params.require(:task).permit(:title, :description, :status, :due_date, :user_id)
    end
end
