module Razorpay
  module RpOrder
    class Api < Razorpay::Base
      attr_reader :order

      def create(order_id)
        @order = Spree::Order.find_by(id: order_id)
        raise "Order not found" unless order

        razorpay_order = Razorpay::Order.create(order_create_params)

        if razorpay_order.try(:id).present?
          log_order_in_db(razorpay_order.id)
          return [razorpay_order.id, order.inr_amt_in_paise]
        end

        ['', 0]
      rescue StandardError => e
        Rails.logger.error("Razorpay Order create failed: #{e.message}")
        ['', 0]
      end

      private

      def order_create_params
        {
          amount: order.inr_amt_in_paise,
          currency: order.currency || 'INR',
          receipt: order.number
        }
      end

      def log_order_in_db(rzp_order_id)
        Spree::RazorpayCheckout.create!(
          order_id: order.id,
          razorpay_order_id: rzp_order_id,
          status: 'created'
        )
      rescue StandardError => e
        Rails.logger.error("Failed to log Razorpay Order in DB: #{e.message}")
      end
    end
  end
end
