module Spree
  class RazorpayController < StoreController
    skip_before_action :verify_authenticity_token

    include Spree::RazorPay

    #Step 1: Create Razorpay Order before payment
    def create_order
      razorpay_order_id = ::Razorpay::RpOrder::Api.new.create(params[:order_id])

      if razorpay_order_id.present?
        render json: { success: true, razorpay_order_id: razorpay_order_id }
      else
        render json: { success: false, error: "Failed to create Razorpay order" }, status: :unprocessable_entity
      end
    end

    #Step 2: Razorpay callback after payment
    def razor_response
      if valid_signature? && razorpay_payment_id.present?
        begin
          gateway.verify_and_capture_razorpay_payment(order, razorpay_payment_id)

          #Update the record created during create_order
          checkout_record = Spree::RazorpayCheckout.find_by(
            order_id: order.id,
            razorpay_order_id: params[:razorpay_order_id]
          )

          if checkout_record
            checkout_record.update!(
              razorpay_payment_id: razorpay_payment_id,
              razorpay_signature: params[:razorpay_signature],
              status: razorpay_payment.status,
              payment_method: razorpay_payment.method,
              card_id: razorpay_payment.card_id,
              bank: razorpay_payment.bank,
              wallet: razorpay_payment.wallet,
              vpa: razorpay_payment.vpa,
              email: razorpay_payment.email,
              contact: razorpay_payment.contact
            )
          else
            Rails.logger.warn("RazorpayCheckout record not found for order #{order.id}")
          end

          # Add payment to Spree order
          order.razor_payment(razorpay_payment, payment_method, params[:razorpay_signature])
          order.next

          flash['order_completed'] = true if order.completed?
          redirect_to checkout_state_path_or_completion and return
        rescue StandardError => e
          Rails.logger.error("Razorpay Error: #{e.message}")
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
      Razorpay::Utility.verify_payment_signature(
        razorpay_order_id: params[:razorpay_order_id],
        razorpay_payment_id: params[:razorpay_payment_id],
        razorpay_signature: params[:razorpay_signature]
      )
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
