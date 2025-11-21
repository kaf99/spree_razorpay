module SpreeRazorpayCheckout
  module Spree
    module OrderDecorator

      def inr_amt_in_paise
        (total.to_f * 100).to_i
      end

      def razor_payment(payment_object, payment_method, razorpay_signature)
        # Optional: save razorpay event info (but DO NOT attach it as payment source)
        ::Spree::RazorpayCheckout.create!(
          order_id: id,
          razorpay_payment_id: payment_object.id,
          razorpay_order_id: payment_object.order_id,
          razorpay_signature: razorpay_signature,
          status: payment_object.status,
          payment_method: payment_object.method,
          card_id: payment_object.card_id,
          bank: payment_object.bank,
          wallet: payment_object.wallet,
          vpa: payment_object.vpa,
          email: payment_object.email,
          contact: payment_object.contact
        )

        # Create the payment properly
        payment = payments.create!(
          payment_method_id: payment_method.id,
          amount: total,
          response_code: payment_object.id
        )

        # Mark payment complete
        payment.complete!

        # Move order forward
        self.next! if self.state != "complete"

        payment
      end

      ::Spree::Order.prepend SpreeRazorpayCheckout::Spree::OrderDecorator
    end
  end
end
