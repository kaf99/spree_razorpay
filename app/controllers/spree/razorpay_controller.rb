module Spree
  class RazorpayController < StoreController
    skip_before_action :verify_authenticity_token

    # ------------------------------
    # Razorpay Create Order (Frontend)
    # ------------------------------
    def create_order
      order = Spree::Order.find_by(id: params[:order_id])
      return render json: { success: false, error: "Order not found" }, status: 404 unless order

      razorpay_order_id, amount = ::Razorpay::RpOrder::Api.new.create(order.id)

      if razorpay_order_id.present?
        render json: {
          success: true,
          razorpay_order_id: razorpay_order_id,
          amount: amount
        }
      else
        render json: { success: false, error: "Razorpay order creation failed" }, status: 422
      end
    end

    # ------------------------------
    # Razorpay Callback Handler
    # ------------------------------
    def razor_response
      order = Spree::Order.find_by(number: params[:order_id] || params[:order_number])
      return redirect_to checkout_state_path(:payment), alert: "Order not found" unless order

      unless valid_signature?
        return redirect_to checkout_state_path(order.state), alert: "Payment signature verification failed"
      end

      begin
        payment_method = Spree::PaymentMethod.find_by(type: "Spree::Gateway::RazorpayGateway")
        razorpay_payment = payment_method.verify_and_capture_razorpay_payment(order, razorpay_payment_id)

        spree_payment = order.razor_payment(
          razorpay_payment,
          payment_method,
          params[:razorpay_signature]
        )

        # Mark payment completed
        spree_payment.complete!

        # Move order to completion
        order.next! until order.completed?

        # Force payment_state = paid
        order.update_column(:payment_state, "paid")

        redirect_to completion_route(order)

      rescue => e
        Rails.logger.error("Razorpay Callback Error: #{e.message}")
        redirect_to checkout_state_path(order.state), alert: "Payment Error: #{e.message}"
      end
    end

    private

    def razorpay_payment_id
      params[:razorpay_payment_id]
    end

    def valid_signature?
      Razorpay::Utility.verify_payment_signature(
        razorpay_order_id: params[:razorpay_order_id],
        razorpay_payment_id: params[:razorpay_payment_id],
        razorpay_signature: params[:razorpay_signature]
      )
    rescue => e
      Rails.logger.error("Razorpay Signature Error: #{e.message}")
      false
    end

    def completion_route(order)
      "/checkout/#{order.guest_token}/complete"
    end
  end
end
