class Api::TasksController < ApplicationController
    before_action :set_task, only: [ :show, :update, :destroy ]

    def index
        form = Tasks::IndexForm.new(index_params)
        return render_invalid_params(form) unless form.valid?

        tasks = Task.assigned_to(Current.user)
        tasks = tasks.with_status(form.status) if form.status.present?
        tasks = tasks.sorted_by(form.sort_by, form.order)

        pagination = paginator.paginate(tasks)
        return render_bad_request(pagination.error_message) unless pagination.success?

        render json: { data: pagination.records, meta: pagination.meta }
    end

    def show
        render json: @task
    end

    def create
        task = Task.new(task_params.merge(user: Current.user))

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
        @task = Task.assigned_to(Current.user).find(params[:id])
    end

    def task_params
        params.require(:task).permit(:title, :description, :status, :due_date)
    end

    def index_params
        params.permit(:status, :sort_by, :order)
    end
end
