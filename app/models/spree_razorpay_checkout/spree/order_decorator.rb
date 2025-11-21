module SpreeRazorpayCheckout
  module Spree
    module OrderDecorator

      def inr_amt_in_paise
        (total * 100).to_i
      end

      def razor_payment(payment_object, payment_method, razorpay_signature)

        # Save Razorpay metadata
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

        # Create payment
        payment = payments.create!(
          payment_method_id: payment_method.id,
          amount: total,
          response_code: payment_object.id
        )

        # 🔥 THIS WAS MISSING → Marks payment as paid
        payment.complete!

        # 🔥 THIS WAS ALSO MISSING → Completes the order
        self.next! until self.completed?

        payment
      end

      ::Spree::Order.prepend SpreeRazorpayCheckout::Spree::OrderDecorator
    end
  end
end
