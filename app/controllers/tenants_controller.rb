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
    @tenant =  Tenant.find(params[:id])
    @tenant.destroy
    redirect_to tenants_path
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
    tenant_result = Tenant.find(params[:id])
    if tenant_result.nil?
      render file: '/public/404.html', status: 404
    else
      @tenant = tenant_result.update(permitted_params,params[:id])
      redirect_to tenant_path(params[:id])
    end
    
  end

  private
  def permitted_params
    params.require(:tenant).permit(:name, :display_name)
  end
end
