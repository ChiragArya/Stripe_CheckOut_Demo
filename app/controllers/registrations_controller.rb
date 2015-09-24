class RegistrationsController < ApplicationController
  before_action :set_registration, only: [:show, :edit, :update, :destroy]

  # GET /registrations
  def index
    @registrations = Registration.all
  end

  # GET /registrations/1
  def show
  end

  # GET /registrations/new
  def new
    @registration = Registration.new
    @course = Course.find_by id: params["course_id"]
  end

  # POST /registrations
  # def create
  #   @registration = Registration.new registration_params.merge(email: stripe_params["stripeEmail"], card_token: stripe_params["stripeToken"])
  #   raise "Please Check Registration Errors" unless @registration.valid?
  #   @registration.process_payment
  #   @registration.save
  #   redirect_to @registration, notice: 'Registration was successfully created.'
  # rescue Exception => e
  #   flash[:error] = e.message
  #   render :new

  # end

  def create
    @registration = Registration.new registration_params
    @registration.process_payment
    if @registration.save
        redirect_to @registration, notice: 'Registration was successfully created.'
    else
        # handle error here
    end
  end

  # POST /registrations/hook
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
    # Use callbacks to share common setup or constraints between actions.
    def set_registration
      @registration = Registration.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def registration_params
      #params.require(:registration).permit(:course_id, :full_name, :company, :telephone, :email, :card_token)
      params.require(:registration).permit(:course_id, :full_name, :company, :telephone, :email, :card_token).merge(email: stripe_params["stripeEmail"], card_token: stripe_params["stripeToken"])
    end

end
