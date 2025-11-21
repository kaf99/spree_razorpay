module Spree
  class RazorpayController < StoreController
    skip_before_action :verify_authenticity_token

    # ---------------------------------
    # Step 1: Create Razorpay Order
    # ---------------------------------
    def create_order
      order = Spree::Order.find_by(number: params[:order_id])
      return render json: { success: false, error: "Order not found" }, status: 404 unless order

      razorpay_order_id = ::Razorpay::RpOrder::Api.new.create(order.number)

      if razorpay_order_id.present?
        Spree::RazorpayCheckout.create!(
          order_id: order.id,
          razorpay_order_id: razorpay_order_id,
          amount: order.total
        )

        render json: {
          success: true,
          razorpay_order_id: razorpay_order_id,
          amount: (order.total * 100).to_i
        }
      else
        render json: { success: false, error: "Razorpay order creation failed" }, status: 422
      end
    end

    # ---------------------------------
    # Step 2: Razorpay Callback
    # ---------------------------------
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

        payment = order.razor_payment(
          razorpay_payment,
          payment_method,
          params[:razorpay_signature]
        )

        payment.complete!

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

    # -----------------------------
    # FIXED SIGNATURE VERIFICATION
    # -----------------------------
    def valid_signature?
      payload = "#{params[:razorpay_order_id]}|#{params[:razorpay_payment_id]}"
      expected_signature = OpenSSL::HMAC.hexdigest(
        'SHA256',
        Spree::Config.razorpay_key_secret,
        payload
      )

      secure_compare(expected_signature, params[:razorpay_signature])
    rescue => e
      Rails.logger.error("Signature failed: #{e.message}")
      false
    end

    # constant-time string comparison
    def secure_compare(a, b)
      ActiveSupport::SecurityUtils.secure_compare(a.to_s, b.to_s)
    end
  end
end
