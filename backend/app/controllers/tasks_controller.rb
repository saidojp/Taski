class TasksController < ApplicationController
  before_action :set_organization
  before_action :check_membership
  before_action :set_task, only: [:show, :update, :destroy]

  # GET /organizations/:organization_id/tasks
  def index
    @tasks = @organization.tasks

    # Filtering
    @tasks = @tasks.where(status: params[:status]) if params[:status].present?
    @tasks = @tasks.where(assignee_id: params[:assignee_id]) if params[:assignee_id].present?
    @tasks = @tasks.where(category: params[:category]) if params[:category].present?

    render json: @tasks
  end

  # GET /organizations/:organization_id/tasks/:id
  def show
    render json: @task
  end

  # POST /organizations/:organization_id/tasks
  def create
    @task = @organization.tasks.build(task_params)
    
    # Auto-invite: if assignee not in org, add them
    auto_invite_assignee if params[:assignee_id].present?
    
    if @task.save
      render json: @task, status: :created
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /organizations/:organization_id/tasks/:id
  def update
    # Auto-invite: if assignee not in org, add them
    auto_invite_assignee if params[:assignee_id].present?
    
    if @task.update(task_params)
      render json: @task
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /organizations/:organization_id/tasks/:id
  def destroy
    @task.destroy
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Organization not found' }, status: :not_found
  end

  def check_membership
    unless @organization.users.exists?(@current_user.id)
      render json: { error: 'Access denied' }, status: :forbidden
    end
  end

  def set_task
    @task = @organization.tasks.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Task not found' }, status: :not_found
  end

  def task_params
    params.permit(:title, :description, :status, :assignee_id, :category)
  end

  def auto_invite_assignee
    assignee_id = params[:assignee_id].to_i
    return if assignee_id.zero?
    
    unless @organization.users.exists?(assignee_id)
      user = User.find_by(id: assignee_id)
      Membership.create(user: user, organization: @organization, role: 'member') if user
    end
  end
end
