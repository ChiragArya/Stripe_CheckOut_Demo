class RegistrationsController < ApplicationController
  before_action :set_registration, only: [:show, :edit, :update, :destroy]

  def index
    @registrations = Registration.all
  end

  def show
  end

  def new
    
    # @registration = @course.registrations.new
    # @course = Course.find(params["course_id"])

    @registration = Registration.new
    @course = Course.new
    @course = Course.find_by id: params["course_id"]
  end

  def create
    @registration = Registration.new registration_params.merge(email: stripe_params["stripeEmail"], card_token: stripe_params["stripeToken"])
    raise "Please Check Registration Errors" unless @registration.valid?
    @registration.process_payment
    @registration.save
    redirect_to @registration, notice: 'Registration was successfully created.'
  rescue Exception => e
    flash[:error] = e.message
    render :new
  end

  protect_from_forgery except: :webhook
  def webhook
    event = Stripe::Event.retrieve(params["id"])

    case event.type
      when "invoice.payment_succeeded" #renew subscription
        Registration.find_by_customer_id(event.data.object.customer).renew
    end
    render status: :ok, json: "success"
  end

  private

    def stripe_params
      params.permit :stripeEmail, :stripeToken
    end
    
    def set_registration
      @registration = Registration.find(params[:id])
    end

    def registration_params
      params.require(:registration).permit(:course_id, :full_name, :company, :telephone, :email, :card_token)
    end

end
