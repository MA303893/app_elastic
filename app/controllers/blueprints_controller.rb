class BlueprintsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :html, :json

  def index
    
  end

  def create

  end

  def destroy
  end

  def update

  end

  def show

  end

  def edit
  end

  def new
    @blueprint = Blueprint.new
  end

  private
  def permitted_params
    params.require(:blueprint).permit(:name, :display_name).merge!(tenant_id: params[:tenant_id], subscription_id: params[:subscription_id])
  end
end
