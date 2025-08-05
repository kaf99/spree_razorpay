<img 
  src="https://github.com/user-attachments/assets/3bcca1bd-5d70-4f0e-9c6d-4f99104d0e93" 
  alt="razorpay" 
  style="height: 100px; border-radius: 12em;"
/>

## Razorpay Extension for Spree Commerce v5
RazorPay is the only payments solution in India that allows businesses to accept, process and disburse payments with its product suite.

## Installation (Traditional)

1. Add this your Gemfile with this line:

    ```ruby
    gem 'spree_razorpay', git: 'https://github.com/umeshravani/spree_razorpay'
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

## Installation (For Docker)

1. Add this your Gemfile with this line:

    ```ruby
    gem 'spree_razorpay', git: 'https://github.com/umeshravani/spree_razorpay'
    ```

2. Install the Gem using Docker's Bundle Install:

    ```ruby
    docker compose run web bundle install
    ```

3. Run Install Generator to Copy Migrations in Docker way:

    ```ruby
    docker compose run web bundle exec rails g spree_razorpay:install
    ```

4. Compile Assests for Razorpay logo & assets (Recommended):
   
    ```ruby
    docker compose run web bundle exec rails assets:precompile
    ```
    
5. Re-Start Server (Recommended):

    ```ruby
    docker compose down
    docker compose up -d
    ```

## Plugin Configuration
6. Get keys from Razorpay Dashboard [here](https://dashboard.razorpay.com/app/website-app-settings/api-keys).

   <img width="1186" height="735" alt="razorpay dashboard" src="https://github.com/user-attachments/assets/f390685d-550b-4814-8785-4fcc32746f15" />

7. Make Sure to include both Razorpay Live & Test Keys from Razorpay Dashboard:

<img width="1121" height="736" alt="Admin Dashboard - Razorpay Plugin" src="https://github.com/user-attachments/assets/f45efc43-b1db-4c79-9ad3-e3d672014676" />


8. Drag Razorpay to Top in Payment Methods to make it Default:

<img width="1121" height="726" alt="Payment Methods - Razorpay Plugin" src="https://github.com/user-attachments/assets/8e39086d-85a6-42a2-b9fb-75299044e6d6" />

## Checkout View

9. Checkout Page:
   
<img width="507" height="639" alt="Razorpay Checkout Page" src="https://github.com/user-attachments/assets/ddca8536-fa94-4502-96fa-4cd2219f3c17" />

10. Razorpay Modal to Capture Payments:

<img width="767" height="728" alt="Razorpay Modal" src="https://github.com/user-attachments/assets/da83105f-8510-44ae-ac7c-28960cf3a0b3" />

11. Order Page (Customer View):

<img width="863" height="733" alt="Razorpay in Order Page Client" src="https://github.com/user-attachments/assets/51b80fe6-4007-4223-b978-8ce65a3238de" />

12. Order Page (Admin View):

<img width="820" height="543" alt="Admin Orders Page Razorpay" src="https://github.com/user-attachments/assets/6d95d1ab-83a0-4ad8-9528-353cc7315630" />

Thankyou for supporting this plugin. if you find any issues related to plugin you are open to contribute and support which can help more Spree users in India.
