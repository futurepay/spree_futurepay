module Spree
  class FuturepayController < Spree::StoreController

    def success
      
    end
    
    def preorder
      require 'uri'
      require 'net/http'
      @order = current_order
      billing_address = Spree::Address.find(@order.bill_address_id)
      shipping_address = Spree::Address.find(@order.ship_address_id)
      country = Spree::Country.find(billing_address.country_id)
      country = country.iso

      fp = PaymentMethod::Futurepay.last()
      #send pre-order request for cart token
      respond_to do |format|
        if @order.currency == "USD" && country == "US"
          state = Spree::State.find(billing_address.state_id)
          shippingCountry = Spree::Country.find(shipping_address.country_id)
          shippingCountry = shippingCountry.iso

          if shipping_address.state_id.present?
            shippingState = Spree::State.find(shipping_address.state_id)
          else
            shippingState = shipping_address.state_name
          end

          shippingCountry = shippingState.country().iso
          fp = PaymentMethod::Futurepay.last()

          if fp.environment == "production"
            uri = URI.parse('https://api.futurepay.com/remote/merchant-request-order-token')
            script_url = "https://api.futurepay.com/remote/cart-integration/"
            gmid = fp.gmid
          else
            uri = URI.parse('https://demo.futurepay.com/remote/merchant-request-order-token')
            script_url = "https://demo.futurepay.com/remote/cart-integration/"
            gmid = "882bb39add08c23107753012b2917bfd1bb28bf8FPM975056"
          end

          preorder_params = { "gmid" => gmid,
                     "first_name" => billing_address.firstname,
                     "last_name"  => billing_address.lastname,
                     "address_line_1" => billing_address.address1,
                     "city" => billing_address.city,
                     "state"  => state.abbr,
                     "country" => country,
                     "zip" => billing_address.zipcode,
                     "phone" => billing_address.phone,
                     "shipping_address_line_1" => shipping_address.address1,
                     "shipping_city" => shipping_address.city,
                     "shipping_state"  => shippingState.abbr,
                     "shipping_country" => shippingCountry,
                     "shipping_zip" => shipping_address.zipcode,
                     "reference" => @order.number,
                     "email" => @order.email,
                     "sku[0]" => "Complete Order",
                     "price[0]" => @order.total,
                     "tax_amount[0]" => 0,
                     "description[0]" => "Total cost of Order",
                     "quantity[0]" => 1
                     }

          http = Net::HTTP.new(uri.host, uri.port)        
          http.use_ssl = true
          if fp.environment == "production"
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          else
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
          request = Net::HTTP::Post.new(uri.request_uri)
          request.set_form_data(preorder_params)
          response = http.request(request)   
          result = response.body.strip

          error_message_found = result.include?("FP_")

          if error_message_found
            if  result.include?("MISSING_REQUIRED_PHONE") 
                result = "There was no phone number entered for your billing address. Please enter a phone number and try again."
            elsif result.include?("NO_ZIP_FOUND") 
                result = "The Zip code you entered for your billing address corresponds to a Military (APO/FPO/DPO), PO Box or other non-physical address. To approve your application we require a Zip code associated with a physical address in the U.S.";
            elsif result.include?("INVALID_TOTAL_TRANSACTION_AMOUNT")
                result = "Your purchase was not successful because the total amount is $0. Please check your cart to ensure items have been added and try again.";
            elsif result.include?("INVALID_EMAIL_FORMAT")
                result = "The email address entered is not valid, please re-enter and try again.";
            elsif result.include?("INVALID_STATE_ZIP_COMBINATION")
                result = "The Zip code does not match the state entered. Please re-enter and try your purchase again.";
            elsif result.include?("INVALID_MERCHANT_STATUS")
                result = "We are unable to process your order with the Merchant. No charges have been applied to your FuturePay tab. Please contact the Merchant for assistance in completing your order. We apologize for any inconvenience this may have caused.";
            elsif result.include?("EXISTING_INVALID_CUSTOMER_STATUS")
                result = "Your purchase was not successful because your account is not in an active state. Please contact FuturePay at support@futurepay.com";
            elsif result.include?("INVALID_SERVER_REQUEST")
                result = "We are unable to process your order with the Merchant. No charges have been applied to your FuturePay tab. Please contact the Merchant for assistance in completing your order. We apologize for any inconvenience this may have caused.";
            elsif result.include?("PRE_ORDER_EXCEEDS_MAXIMUM")
                result = "This order exceeds the maximum available amount on a FuturePay account.";
            else
                result = "There was a problem creating your order. No changes have been applied to your FuturePay tab. Please contact FuturePay at support@futurepay.com";
            end
          else
            result = script_url + result
          end
        else
          result = "FuturePay is only available for Payments in US Dollars, for American residents.";
        end        
        format.json { render :json => result } 
      end
    end
    
    
    
    def confirm
      purchase_result = ActiveSupport::JSON.decode(params[:info])
      order = current_order
      fp = PaymentMethod::Futurepay.last()

      if purchase_result['transaction_id'].present?

          if fp.environment == "production"
            uri = URI.parse('https://api.futurepay.com/remote/merchant-order-verification')
            gmid = fp.gmid
          else
            uri = URI.parse('https://demo.futurepay.com/remote/merchant-order-verification')
            gmid = "882bb39add08c23107753012b2917bfd1bb28bf8FPM975056"
          end

        params = { "gmid" => gmid,
                   "otxnid" => purchase_result['transaction_id']
                   }        
        http = Net::HTTP.new(uri.host, uri.port)        
        http.use_ssl = true
          if fp.environment == "production"
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          else
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
        request = Net::HTTP::Post.new(uri.request_uri)
        request.set_form_data(params)
        response = http.request(request)     
        order_verification_result = ActiveSupport::JSON.decode(response.body.strip)   
        
      else
       #the response from fp is that the sale was nto successful, errors should be displayed here 
       flash.notice = Spree.t(:payment_processing_failed)
       redirect_to checkout_state_path(order.state) and return        

      end
      #this is the verify api check
      if order_verification_result['OrderStatusCode'] == "ACCEPTED"
                               
          order = current_order || raise(ActiveRecord::RecordNotFound)
          payment = order.payments.last
          payment.update_attributes!({
              :source => Spree::FuturepayCheckout.create({
              :transaction_id => order_verification_result['OrderReference'],
              :code => order_verification_result['OrderStatusCode'],
              :total => order_verification_result['TotalPrice'].to_f
            }),
            :response_code => order_verification_result['OrderStatusCode'],
            :amount => order.total,
            :payment_method => fp
          })

         order.next   

        if order.complete?
          flash.notice = Spree.t(:order_processed_successfully)
          session[:order_id] = nil
          redirect_to order_path(order, :token => order.guest_token)
        else
          redirect_to checkout_state_path(order.state)
        end
                       
      else
        flash.notice = "The FuturePay payment was not successful."
        redirect_to order_path(order, :token => order.guest_token)
      end            
    end      
  end
end

