## Razorpay Extension for Spree Commerce v5
RazorPay is the only payments solution in India that allows businesses to accept, process and disburse payments with its product suite.

## Installation

1. Add this your Gemfile with this line:

    ```ruby
    gem 'spree_razorpay', github: 'umeshravani/spree-razorpay'
    ```

2. Install the Gem using Bundle Install:

    ```ruby
    bundle install
    ```

3. Copy & Run Migrations:

    ```ruby
    bundle exec rails g spree_razorpay:install
    ```

4. Compile Assests for Proper Images & JS loading:
   
    ```ruby
    RAILS_ENV=development bin/rails assets:precompile
    ```
    
5. Start Server:

    ```ruby
    foreman start -f Procfile.dev
    ```

## Plugin Configuration
    
6. Make Sure to include both Razorpay Live & Test Keys from Razorpay Dashboard:

<img width="1121" height="736" alt="Admin Dashboard - Razorpay Plugin" src="https://github.com/user-attachments/assets/f45efc43-b1db-4c79-9ad3-e3d672014676" />


5. Drag Razorpay to Top in Payment Methods to make it Default:

<img width="1121" height="726" alt="Payment Methods - Razorpay Plugin" src="https://github.com/user-attachments/assets/8e39086d-85a6-42a2-b9fb-75299044e6d6" />

## Checkout View

6. Checkout Page:
   
<img width="507" height="639" alt="Razorpay Checkout Page" src="https://github.com/user-attachments/assets/ddca8536-fa94-4502-96fa-4cd2219f3c17" />

7. Razorpay Modal to Capture Payments:

<img width="767" height="728" alt="Razorpay Modal" src="https://github.com/user-attachments/assets/da83105f-8510-44ae-ac7c-28960cf3a0b3" />

8. Order Page (Customer View):

<img width="863" height="733" alt="Razorpay in Order Page Client" src="https://github.com/user-attachments/assets/51b80fe6-4007-4223-b978-8ce65a3238de" />

9. Order Page (Admin View):

<img width="820" height="543" alt="Admin Orders Page Razorpay" src="https://github.com/user-attachments/assets/6d95d1ab-83a0-4ad8-9528-353cc7315630" />

Thankyou for supporting this plugin. if you find any issues related to plugin you are open to contribute and support which can help more Spree users in India.
