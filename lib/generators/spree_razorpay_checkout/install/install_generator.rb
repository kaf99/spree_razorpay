module SpreeRazorpayCheckout
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__) # if you use templates
      class_option :migrate, type: :boolean, default: true

      def add_javascripts
        #append_file 'vendor/assets/javascripts/spree/frontend/all.js', "//= require spree/frontend/spree_razorpay_checkout\n"
        #append_file 'vendor/assets/javascripts/spree/frontend/all.js', "//= require spree/frontend/process_razorpay\n"
      end

      def add_migrations
        run 'bin/rails railties:install:migrations FROM=spree_razorpay_checkout'
      end

      def run_migrations
        if options[:migrate]
          run 'bin/rails db:migrate'
        else
          say_status :skip, "Skipped running migrations. You can run them later with `bin/rails db:migrate`.", :yellow
        end
      end
    end
  end
end
