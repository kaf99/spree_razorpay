module Spree
  class RazorpayController < StoreController
    skip_before_action :verify_authenticity_token

    include Spree::RazorPay

    def razor_response
      if valid_signature? && razorpay_payment_id.present?
        begin
          gateway.verify_and_capture_razorpay_payment(order, razorpay_payment_id)
          order.razor_payment(razorpay_payment, payment_method, params[:razorpay_signature])
          order.next

          flash['order_completed'] = true if order.completed?
          redirect_to checkout_state_path_or_completion and return
        rescue StandardError => e
          flash[:error] = "Razorpay Error: #{e.message}"
        end
      else
        flash[:error] = 'Razorpay payment verification failed'
      end

      redirect_to checkout_state_path(order.state)
    end

    private

    def razorpay_payment_id
      params[:razorpay_payment_id]
    end

    def razorpay_payment
      @razorpay_payment ||= Razorpay::Payment.fetch(razorpay_payment_id)
    end

    def valid_signature?
      Razorpay::Utility.verify_payment_signature(update_razorpay_response)
    rescue Razorpay::Error => e
      Rails.logger.error("Razorpay signature verification failed: #{e.message}")
      false
    end

    def order
      @order ||= Spree::Order.find_by(number: params[:order_id])
    end

    def payment_method
      @payment_method ||= Spree::PaymentMethod.find(params[:payment_method_id])
    end

    def gateway
      @gateway ||= payment_method
    end

    def checkout_state_path_or_completion
      order.completed? ? completion_route : checkout_state_path(order.state)
    end

    def completion_route
      order_path(order)
    end
  end
end
