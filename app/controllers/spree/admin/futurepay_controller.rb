module Spree
  module Admin
    class FuturepayController < Spree::Admin::BaseController


      def index
        
      end

      def create                                   

      require 'uri'
      require 'net/http'  
        
        uri = URI.parse('https://api.futurepay.com/remote/merchant-request-key')
        if params[:selected_state_code].present?
          params[:region_code] = Spree::State.find(params[:selected_state_code][:id]).abbr
        end
        if params[:selected_state_name].present?
          params[:region_code] = params[:selected_state_name][:id]
        end

        
        if params[:type] == "signup"
          params[:country_code] = Spree::Country.find(params[:selected_country][:id]).iso
        end
        request_params = params
        http = Net::HTTP.new(uri.host, uri.port)        
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        request = Net::HTTP::Post.new(uri.request_uri,)
        request.set_form_data(request_params)
        response = http.request(request)     
        result = JSON.parse(response.body)
        # search the api response for an error code


        if result["error"] == 1

          flash.notice = result["message"]
          redirect_to admin_futurepay_index_path and return  

        else

            fp = Spree::PaymentMethod::Futurepay.last()

            if fp.instance_of?(PaymentMethod::Futurepay)
             #set the gmid for the existing futurepay payment method (if it exists)
             fp.preferred_gmid    = result["key"]
             fp.save       

            flash[:success] = result["message"]
            redirect_to admin_futurepay_index_path and return  

            else
              #create new futurepay payment method
              new_fp = PaymentMethod::Futurepay.new()
              new_fp.type              = "Spree::PaymentMethod::Futurepay"
              new_fp.name              = "FuturePay"
              new_fp.description       = "Buy now and pay later."
              new_fp.active            = true
              new_fp.environment       = "production"
              new_fp.preferred_gmid    = result["key"]
              new_fp.save

              flash[:success] = "FuturePay has succesfully been added as a Payment Method and is ready to start taking orders."
              redirect_to admin_futurepay_index_path and return     

            end
        end                              
      end                       
    end
  end
end

