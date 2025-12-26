class OrganizationsController < ApplicationController
  # GET /organizations
  def index
    render json: @current_user.organizations
  end

  # POST /organizations
  def create
    @organization = Organization.new(organization_params)

    if @organization.save
      # Automatically add creator as member (and maybe admin in future)
      Membership.create!(user: @current_user, organization: @organization, role: 'owner')
      render json: @organization, status: :created
    else
      render json: { errors: @organization.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /organizations/:id/users
  def users
    @organization = Organization.find(params[:id])
    
    # Check membership first (security)
    unless @organization.users.exists?(@current_user.id)
      return render json: { error: 'Access denied' }, status: :forbidden
    end

    render json: @organization.users.select(:id, :name, :email)
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Organization not found' }, status: :not_found
  end

  private

  def organization_params
    params.permit(:name)
  end
end
