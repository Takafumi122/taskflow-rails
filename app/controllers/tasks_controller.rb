class TasksController < ApplicationController
  before_action :set_task, only: %i[show edit update destroy transition]

  def index
    load_board
  end

  def show; end

  def new
    @task = @demo_session.tasks.new(status: "todo", priority: "medium")
  end

  def edit; end

  def create
    @task = @demo_session.tasks.new(task_params)
    if @task.save
      redirect_to root_path, notice: "タスクを作成しました。", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params)
      redirect_to task_path(@task), notice: "タスクを更新しました。", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy!
    redirect_to root_path, notice: "タスクを削除しました。", status: :see_other
  end

  def transition
    if @task.transition_to(params[:status])
      respond_to do |format|
        format.html { redirect_to root_path(filter_params), notice: "ステータスを更新しました。", status: :see_other }
        format.turbo_stream { load_board; render :transition }
      end
    else
      render plain: @task.errors.full_messages.join("、"), status: :unprocessable_entity
    end
  end

  private

  def set_task
    @task = @demo_session.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :status, :priority, :due_date)
  end

  def filter_params
    params.permit(:status_filter, :priority_filter, :overdue).to_h
  end

  def load_board
    @filters = filter_params
    @counts = @demo_session.tasks.group(:status).count
    @total = @counts.values.sum
    @completion_rate = @total.zero? ? 0 : ((@counts.fetch("done", 0).to_f / @total) * 100).round
    @tasks = @demo_session.tasks
    @tasks = @tasks.where(status: @filters["status_filter"]) if Task::STATUSES.key?(@filters["status_filter"])
    @tasks = @tasks.where(priority: @filters["priority_filter"]) if Task::PRIORITIES.key?(@filters["priority_filter"])
    @tasks = @tasks.overdue if @filters["overdue"] == "1"
    @grouped_tasks = @tasks.ordered.group_by(&:status)
  end
end
