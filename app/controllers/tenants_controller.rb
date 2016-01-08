class TenantsController < ApplicationController
  def index
    @tenants = Tenant.all
  end

  def new
    @tenant = Tenant.new
  end

  def create
    @tenant = Tenant.new
    id = @tenant.save(permitted_params)
    redirect_to tenant_path(id)
  end

  def destroy
  end

  def show
    @tenant = Tenant.find(params[:id])
    if @tenant.nil?
      render file: '/public/404.html', status: 404
    end
  end

  def edit
    @tenant = Tenant.find(params[:id])
    if @tenant.nil?
      render file: '/public/404.html', status: 404
    end
  end

  def update
    @tenant = Tenant.find(params[:id])
    if @tenant.nil?
      render file: '/public/404.html', status: 404
    end
    @tenant.update(permitted_params)
  end

  private
  def permitted_params
    # params.require(:id)
    params.require(:tenant).permit(:name, :display_name)
  end
end
