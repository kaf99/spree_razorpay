module SpreeRazorpayCheckout
  module Spree
    module OrderDecorator

      def inr_amt_in_paise
        (total.to_f * 100).to_i
      end

      def razor_payment(payment_object, payment_method, razorpay_signature)
        # Create or update Spree Razorpay Checkout record
        source_record = ::Spree::RazorpayCheckout.create!(
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

        # Create payment inside Spree
        payment = payments.create!(
          source: source_record,
          payment_method: payment_method,
          amount: total,
          response_code: payment_object.id   # Razorpay transaction ID
        )

        # 🔥 IMPORTANT FIX — Mark payment as completed
        payment.complete!

        # 🔥 Advance order if needed
        if self.state != "complete"
          self.next! rescue nil
        end

        payment
      end

      ::Spree::Order.prepend SpreeRazorpayCheckout::Spree::OrderDecorator
    end
  end
end
