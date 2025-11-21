module Spree
  class RazorpayController < StoreController
    skip_before_action :verify_authenticity_token

    # ------------------------------
    # Create Razorpay Order (step 1)
    # ------------------------------
    def create_order
      order = Spree::Order.find_by(number: params[:order_id])
      return render json: { success: false, error: "Order not found" }, status: 404 unless order

      razorpay_order_id = ::Razorpay::RpOrder::Api.new.create(order.number)

      if razorpay_order_id.present?
        # Store record for callback verification
        Spree::RazorpayCheckout.create!(
          order_id: order.id,
          razorpay_order_id: razorpay_order_id,
          amount: order.total
        )

        render json: {
          success: true,
          razorpay_order_id: razorpay_order_id,
          amount: order.total.to_f * 100
        }
      else
        render json: { success: false, error: "Razorpay order creation failed" }, status: 422
      end
    end

    # ------------------------------
    # Razorpay Callback (step 2)
    # ------------------------------
    def razor_response
      order = Spree::Order.find_by(number: params[:order_id])
      return redirect_to checkout_state_path(:payment), alert: "Order not found" unless order

      unless valid_signature?
        return redirect_to checkout_state_path(order.state), alert: "Payment verification failed"
      end

      begin
        payment_method = Spree::PaymentMethod.find_by(type: "Spree::Gateway::RazorpayGateway")

        razorpay_payment = payment_method.verify_and_capture_razorpay_payment(
          order,
          razorpay_payment_id
        )

        # Create payment inside spree
        payment = order.razor_payment(
          razorpay_payment,
          payment_method,
          params[:razorpay_signature]
        )

        payment.complete!  # ensure Spree state is updated

        # Move to completion
        order.next! until order.completed?

        order.update_column(:payment_state, "paid")

        redirect_to order_path(order)

      rescue => e
        Rails.logger.error("Razorpay error: #{e.message}")
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
      Rails.logger.error("Signature failed: #{e.message}")
      false
    end
  end
end
