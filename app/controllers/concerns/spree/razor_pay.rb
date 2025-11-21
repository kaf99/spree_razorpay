module Spree
  module RazorPay
    extend ActiveSupport::Concern

    def update_razorpay_checkout
      return unless order
      razorpay_checkout = Spree::RazorpayCheckout.find_or_initialize_by(order_id: order.id)
      razorpay_checkout.assign_attributes(update_razorpay_response)
      razorpay_checkout.save! if razorpay_checkout.changed?
    rescue => e
      Rails.logger.error("Failed to update RazorpayCheckout: #{e.message}")
    end

    def update_razorpay_response
      {
        razorpay_payment_id: params['razorpay_payment_id'],
        razorpay_order_id: params['razorpay_order_id'],
        razorpay_signature: params['razorpay_signature'],
        status: (defined?(razorpay_payment) && razorpay_payment.try(:status)) || params['status']
      }
    end
  end
end
