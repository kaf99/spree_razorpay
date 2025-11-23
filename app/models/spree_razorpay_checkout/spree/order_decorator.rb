module SpreeRazorpayCheckout
module Spree
module OrderDecorator

```
  # Convert total to paise (for Razorpay)
  def inr_amt_in_paise
    (total.to_f * 100).to_i
  end

  # Create a Spree::Payment from Razorpay response safely
  def razor_payment(payment_object, payment_method)
    # Use safe hash to ignore nil fields
    source_attrs = {
      order_id: id,
      razorpay_payment_id: payment_object.id,
      razorpay_order_id: payment_object.order_id,
      razorpay_signature: payment_object.try(:razorpay_signature),
      status: payment_object.status
    }

    # Optional fields only if present
    [:payment_method, :card_id, :bank, :wallet, :vpa, :email, :contact].each do |f|
      source_attrs[f] = payment_object.send(f) if payment_object.respond_to?(f) && payment_object.send(f).present?
    end

    source = ::Spree::RazorpayCheckout.create!(source_attrs)

    payment = payments.create!(
      source: source,
      payment_method: payment_method,
      amount: total,
      response_code: payment_object.id
    )

    # Complete payment safely
    payment.complete! if payment.respond_to?(:complete!)

    # Update order payment_state if all payments are completed
    if payments.completed.count == payments.count
      update(payment_state: 'paid', completed_at: Time.current)
    end

    payment
  rescue StandardError => e
    Rails.logger.error "Razorpay Payment Error for order #{id}: #{e.message}"
    nil
  end

  ::Spree::Order.prepend SpreeRazorpayCheckout::Spree::OrderDecorator
end
```

end
end
