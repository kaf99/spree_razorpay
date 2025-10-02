# app/models/spree/razorpay_checkout.rb
module Spree
  class RazorpayCheckout < Spree::Base
    self.table_name = 'spree_razorpay_checkouts' # matches your migration

    belongs_to :order, class_name: 'Spree::Order', foreign_key: 'order_id', optional: false

    enum status: { pending: 0, active: 1, archived: 2 }, _prefix: true

    validates :order_id, presence: true
    validates :razorpay_order_id, uniqueness: true, allow_nil: true

    serialize :response_data, JSON

    def mark_paid!(payload = {})
      self.status = :active
      self.response_data = payload
      save!
    end

    def mark_failed!(payload = {})
      self.status = :archived
      self.response_data = payload
      save!
    end
  end
end
