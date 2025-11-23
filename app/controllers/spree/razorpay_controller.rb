# app/controllers/spree/razorpay_controller.rb

module Spree
class RazorpayController < Spree::StoreController
skip_before_action :verify_authenticity_token

```
# Razorpay webhook endpoint
# POST /razorpay/callback
def razor_response
  # Parse incoming JSON from Razorpay
  payload = request.body.read
  signature = request.headers['X-Razorpay-Signature'] || params[:razorpay_signature]

  unless verify_razorpay_signature(payload, signature)
    render json: { error: "Invalid signature" }, status: 400
    return
  end

  event = JSON.parse(payload) rescue nil
  unless event.present? && event['event'] == 'payment.captured'
    render json: { error: "Invalid event" }, status: 400
    return
  end

  payment_data = event['payload']['payment']['entity']

  order_number = payment_data['notes']['order_number'] || payment_data['order_id']
  order = Spree::Order.find_by(number: order_number)

  unless order
    render json: { error: "Order not found" }, status: 404
    return
  end

  # Process payment via your existing razor_payment decorator
  begin
    pm = Spree::PaymentMethod.find_by(type: "Spree::Gateway::RazorpayGateway", active: true)
    payment_object = OpenStruct.new(
      id: payment_data['id'],
      order_id: payment_data['order_id'],
      status: payment_data['status'],
      amount: payment_data['amount']
    )

    sp = order.razor_payment(payment_object, pm, signature)
    sp.complete! unless sp.completed?
    order.next! until order.completed?
    order.update(payment_state: "paid", completed_at: Time.current)

    render json: { success: true }, status: 200
  rescue => e
    Rails.logger.error "[RazorpayWebhook] Failed to process order #{order_number}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    # Still return 200 to Razorpay to avoid retries
    render json: { success: false }, status: 200
  end
end

private

# Verify webhook signature using Razorpay key secret
def verify_razorpay_signature(payload, signature)
  return false unless signature.present? && ENV['RAZORPAY_KEY_SECRET'].present?

  secret = ENV['RAZORPAY_KEY_SECRET']
  computed_signature = OpenSSL::HMAC.hexdigest('SHA256', secret, payload)
  ActiveSupport::SecurityUtils.secure_compare(computed_signature, signature)
end
```

end
end
