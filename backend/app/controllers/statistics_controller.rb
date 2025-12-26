class StatisticsController < ApplicationController
  before_action :set_organization
  before_action :check_membership

  # GET /organizations/:organization_id/statistics
  def index
    # Fetch latest statistics for each user in the organization
    @stats = TaskStatistic.where(organization: @organization)
                          .order(created_at: :desc)
                          .limit(@organization.users.count) # Simple naive approach: get last N records approx

    # Better approach: Get latest per user
    latest_ids = TaskStatistic.where(organization: @organization)
                              .group(:user_id)
                              .maximum(:id)
                              .values

    @stats = TaskStatistic.where(id: latest_ids).includes(:user)

    render json: @stats.as_json(include: { user: { only: [:id, :name] } })
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
end
