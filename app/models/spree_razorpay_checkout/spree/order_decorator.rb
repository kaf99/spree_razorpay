module SpreeRazorpayCheckout
  module Spree
    module OrderDecorator

      # Convert total to paise (for Razorpay)
      def inr_amt_in_paise
        (total * 100).to_i
      end

      # Create a Spree::Payment from Razorpay response
      def razor_payment(payment_object, payment_method, razorpay_signature)
        source = ::Spree::RazorpayCheckout.create!(
          order_id: id,
          razorpay_payment_id: payment_object.id,
          razorpay_order_id: payment_object.order_id,
          razorpay_signature: razorpay_signature,
          status: payment_object.status,
          card_id: payment_object.card_id,
          bank: payment_object.bank,
          wallet: payment_object.wallet,
          vpa: payment_object.vpa,
          email: payment_object.email,
          contact: payment_object.contact
        )

        payment = payments.create!(
          source: source,
          payment_method: payment_method,
          amount: total,
          response_code: payment_object.id
        )

        payment
      end

      ::Spree::Order.prepend SpreeRazorpayCheckout::Spree::OrderDecorator
    end
  end
end
