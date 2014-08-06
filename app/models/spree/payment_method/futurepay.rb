module Spree

  class PaymentMethod::Futurepay < PaymentMethod

    preference :gmid, :string

    def gmid   
      return  preferred_gmid      
    end

    def confirm_url
      "payment/futurepay/confirm" 
    end

    def preOrderUrl
      "payment/futurepay"
    end

    def can_void?(payment)
      false
    end

    def auto_capture?
      true
    end
    
    def can_credit?(payment)
      false
    end

    def purchase(amount, source, gateway_options = {})
      
      Class.new do
        def success?; true; end
        def authorization; nil; end
      end.new

      ActiveMerchant::Billing::Response.new(true, "FuturePay Purchase Successful",{:amount => amount, :transaction_id => source[:transaction_id], :result => source[:code], :created_at => source[:created_at]},{})

    end
    

  def refund(payment, amount)

      require 'uri'
      require 'net/http'   
      
      #send pre-order request for cart token
      refund_type = payment.amount == amount.to_f ? "Full" : "Partial"
      order = Spree::Order.find_by_id(payment[:order_id])
      fp = PaymentMethod::Futurepay.last()
        if fp.environment == "production"
          uri = URI.parse('https://api.futurepay.com/remote/merchant-returns')
          gmid = fp.gmid
        else
          uri = URI.parse('https://demo.futurepay.com/remote/merchant-returns')
          gmid = "882bb39add08c23107753012b2917bfd1bb28bf8FPM975056"
        end

      refund_params = { 
                 "gmid"  => gmid,
                 "reference"  => order[:number],
                 "total_price"  => amount
                 }

      http = Net::HTTP.new(uri.host, uri.port)        
      http.use_ssl = true
      if fp.environment == "production"
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      else
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(refund_params)
      response = http.request(request)   
      result = ActiveSupport::JSON.decode(response.body.strip) 

      
        if result['status'] == "FP_REFUND_SUCCESSFUL"          
          
          payment.class.create!({
              :source => Spree::FuturepayCheckout.create({
              :transaction_id => result['TransactionReference'],
              :code => result['status'],
              :total => amount.to_f
            }),
            :order => payment.order,
            :payment_method => fp,
            :amount => amount.to_f.abs * -1,
            :response_code => result['TransactionReference'],
            :state => 'completed'
          })

        else
      
          payment.class.create!({
              :source => Spree::FuturepayCheckout.create({
              :code => result['status'],
              :total => amount.to_f
            }),
            :order => payment.order,
            :payment_method => fp,
            :amount => amount.to_f.abs * -1,
            :response_code => result['status'],
            :state => 'failed'
          })
      
        end
      result
    end
  end
end
