module Spree
  module OrderDecorator
    def razor_payment(payment_object, payment_method, signature)
      raise "Missing payment_object" if payment_object.nil?
      raise "Missing payment_method" if payment_method.nil?

      payment = payments.create!(
        amount: total,
        payment_method: payment_method,
        response_code: payment_object.id
      )

      payment.started_processing!
      payment.complete!

      # Advance order state until completed
      next! while state != "complete"

      update!(
        payment_state: "paid",
        completed_at: Time.current
      )

      payment
    end
  end
end

::Spree::Order.prepend(Spree::OrderDecorator)
