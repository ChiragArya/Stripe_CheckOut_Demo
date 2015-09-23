class Registration < ActiveRecord::Base
  belongs_to :course

  def process_payment
  	#For Simple Checkout
  	#customer = Stripe::Customer.create email: email, card: card_token
  	#Added Plan ID For Recurring Payments
  	customer_data = {email: email, card: card_token}.merge((course.plan.blank?)? {}: {plan: course.plan})
  	customer = Stripe::Customer.create customer_data

      Stripe::Charge.create customer: customer.id,
                            amount: course.price * 100,
                            description: course.name,
                            currency: 'usd'
      #Annotate Customer Id when Registration is Created
      cusotmer_id = customer.id

  end

#renew adding one month to the registration end date
  def renew
  	update_attibute :end_date, Date.today + 1.month
  end

end
