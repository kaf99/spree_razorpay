# app/models/spree/order_decorator.rb
module Spree
  module OrderDecorator
    def complete!
      # if order has a payment by Razorpay, require that there is at least one paid checkout record
      razorpay_payments = payments.select { |p| p.payment_method&.class&.name == 'Spree::PaymentMethod::Razorpay' || p.response_code.present? }
      if razorpay_payments.any?
        paid_checkout_exists = razorpay_payments.any? do |p|
          Spree::RazorpayCheckout.exists?(order_id: id, razorpay_payment_id: p.response_code, status: Spree::RazorpayCheckout.statuses[:paid])
        end

        unless paid_checkout_exists
          raise Spree::Core::GatewayError, "Payment not confirmed"
        end
      else
        # if no razorpay payments, fall back to ensure there is at least one completed payment
        if payments.valid.none?(&:completed?)
          raise Spree::Core::GatewayError, "Payment not confirmed"
        end
      end

      super
    end
  end
end

Spree::Order.prepend Spree::OrderDecorator
