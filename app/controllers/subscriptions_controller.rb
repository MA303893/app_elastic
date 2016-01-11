class SubscriptionsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def index
    @tenant =  Tenant.find(params[:tenant_id])
    @subscriptions = @tenant.subscriptions
    puts @subscriptions
    #@subcriptions = Subscription.all(params[:tenant_id])
  end

  def create
    @subcription = Subscription.new
    
  end

  def show
  end

  def edit
  end

  def new
    @subcriptions = Subscription.new
  end

  private
  def permitted_params
    params.require(:subscription).permit(:name, :display_name, :budget, :tenant_id).merge!(tenant_id: params[:tenant_id])
  end
end
