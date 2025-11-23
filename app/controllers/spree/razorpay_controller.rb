def razor_response
  order = Spree::Order.find_by(number: params[:order_id] || params[:order_number])
  unless order
    flash[:error] = "Order not found."
    return redirect_to spree.root_path
  end

  unless valid_signature?
    flash[:error] = "Payment signature verification failed."
    return redirect_to spree.root_path
  end

  begin
    # Capture payment **after ensuring order exists**
    razorpay_payment = gateway.verify_and_capture_razorpay_payment(order, razorpay_payment_id)

    # Create Spree payment record safely
    spree_payment = order.razor_payment(razorpay_payment, payment_method, params[:razorpay_signature])

    # Complete payment if method exists
    spree_payment.complete! if spree_payment.respond_to?(:complete!)

    # Advance order state safely
    while !order.completed?
      order.next! rescue break
    end

    # Force payment_state
    order.update(payment_state: 'paid') if order.respond_to?(:payment_state)

    # Redirect to safe route
    redirect_to completion_route(order)

  rescue StandardError => e
    Rails.logger.error("Razorpay Callback Error: #{e.class} - #{e.message}\n#{e.backtrace.join("\n")}")
    flash[:error] = "Payment processed but order could not be completed. Contact support."
    redirect_to spree.root_path
  end
end

private

def completion_route(order)
  token = order.respond_to?(:guest_token) ? order.guest_token : order.token
  if token.present?
    "/checkout/#{token}/complete"
  else
    spree.root_path
  end
end
