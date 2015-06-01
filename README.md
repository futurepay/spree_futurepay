Spree FuturePay
==============

The FuturePay for Spree gem allows you to accept online payments via FuturePay. FuturePay is your safe and secure alternative payment option when offering your customers a card free choice. With FuturePay, customers can buy now and pay later with one click, creating a streamlined checkout process on every device. With guaranteed payments and an easy integration, merchants can start attracting new customers instantly. To learn more about how FuturePay can benefit your business, visit https://www.futurepay.com or contact us today.
Thanks!

Installation
------------

Add spree_futurepay to your Gemfile:

```ruby
gem 'spree_futurepay' , :github => "jeteague/spree_futurepay", :branch => "2-3-stable"
```

Install the gem using Bundler:

```shell
bundle install
bundle exec rails g spree_futurepay:install
```

Usage
-----
Haven't signed up for a FuturePay Merchant account yet? New merchants can easily add FuturePay as a payment method by selecting FuturePay from the Configuration tab sidebar and clicking the "Get Started Now" button.  Here you can enter your merchant information and once successfully completed, FuturePay will be activated as a new payment method in your cart.

If you've already signed up for a FuturePay Merchant account you can add FuturePay as a new Payment Method from the Configuration tab in your Spree administration area simply by entering your API key.  Alternatively, by selecting the FuturePay option from the Configuration sidebar you can activate FuturePay by clicking the "Activate FuturePay" button and entering your FuturePay Merchant credentials.

Completed orders can have partial or full refunds issued by selecting the Orders payments, picking the desired FuturePay payment to be refunded, and then clicking the "Refund" button.

Sandbox Usage
-------------

When the payment method environment is set to development, all FuturePay API calls will be directed to the FuturePay sandbox environment. If you have any questions contact merchant@futurepay.com.


Copyright (c) 2014 FuturePay, released under the GPL License
