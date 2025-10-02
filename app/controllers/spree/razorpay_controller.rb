# app/controllers/spree/razorpay_controller.rb

module Spree
  class RazorpayController < Spree::StoreController
    skip_before_action :verify_authenticity_token, only: [:callback]

    def create
      order = current_order || raise("No order found")

      checkout = Spree::RazorpayCheckout.create!(
        order: order,
        amount: (order.total * 100).to_i,  # Amount in paise
        currency: order.currency,
        status: 'initiated'
      )

      # Create Razorpay order
      razorpay_order = Razorpay::Order.create(
        amount: checkout.amount,
        currency: checkout.currency,
        receipt: checkout.id,
        payment_capture: 1
      )

      checkout.update!(razorpay_order_id: razorpay_order.id)

      render json: { checkout_id: checkout.id, razorpay_order_id: razorpay_order.id }
    end

    def callback
      checkout = Spree::RazorpayCheckout.find(params[:checkout_id])

      if RazorpaySignature.verify?(params[:razorpay_order_id], params[:razorpay_payment_id], params[:razorpay_signature], Rails.application.credentials.razorpay[:key_secret])
        checkout.update!(status: 'paid', payment_id: params[:razorpay_payment_id])
        checkout.order.complete!
        redirect_to order_path(checkout.order), notice: "Payment successful"
      else
        checkout.update!(status: 'failed')
        redirect_to cart_path, alert: "Payment verification failed"
      end
    end
  end
end
