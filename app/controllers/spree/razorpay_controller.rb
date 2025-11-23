module Spree
class RazorpayController < Spree::StoreController
skip_before_action :verify_authenticity_token, only: [:razor_response]

```
# POST /razorpay/callback
def razor_response
  # 1️⃣ Find order
  order = Spree::Order.find_by(number: params[:order_id] || params[:order_number])
  unless order
    flash[:error] = "Order not found."
    return redirect_to spree.root_path
  end

  # 2️⃣ Verify Razorpay signature
  unless valid_signature?
    flash[:error] = "Payment signature verification failed."
    return redirect_to spree.root_path
  end

  begin
    # 3️⃣ Capture payment from Razorpay
    razorpay_payment = gateway.verify_and_capture_razorpay_payment(order, params[:razorpay_payment_id])

    # 4️⃣ Create Spree payment record
    spree_payment = order.razor_payment(razorpay_payment, payment_method, params[:razorpay_signature])

    # 5️⃣ Complete payment
    spree_payment.complete! if spree_payment.respond_to?(:complete!)

    # 6️⃣ Advance order state safely
    while !order.completed?
      order.next! rescue break
    end

    # 7️⃣ Force payment_state
    order.update(payment_state: 'paid') if order.respond_to?(:payment_state)

    # 8️⃣ Redirect to order completion
    redirect_to completion_route(order)

  rescue StandardError => e
    Rails.logger.error("Razorpay Callback Error: #{e.class} - #{e.message}\n#{e.backtrace.join("\n")}")
    flash[:error] = "Payment processed but order could not be completed. Contact support."
    redirect_to spree.root_path
  end
end

private

# Returns the Razorpay gateway object
def gateway
  @gateway ||= Spree::PaymentMethod.find_by(type: "Spree::Gateway::RazorpayGateway", active: true)
end

# Returns the payment method object for Spree::Payment
def payment_method
  gateway
end

# Validates Razorpay signature
def valid_signature?
  secret = ENV['RAZORPAY_KEY_SECRET']
  order_id = params[:razorpay_order_id]
  payment_id = params[:razorpay_payment_id]
  signature = params[:razorpay_signature]

  payload = "#{order_id}|#{payment_id}"
  expected_signature = OpenSSL::HMAC.hexdigest('SHA256', secret, payload)
  expected_signature == signature
end

# Redirect route after order completion
def completion_route(order)
  token = order.respond_to?(:guest_token) ? order.guest_token : order.token
  if token.present?
    "/checkout/#{token}/complete"
  else
    spree.root_path
  end
end
```

end
end
