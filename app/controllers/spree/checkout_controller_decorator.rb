module Spree
  CheckoutController.class_eval do
        
    def update
      if @order.state == 'payment'
        #if the order is in payment state, and the chosen method is FP, go straight to confirm page
        @pay_method = Spree::PaymentMethod.find(params[:order][:payments_attributes].last[:payment_method_id])
        if @pay_method.instance_of? Spree::PaymentMethod::Futurepay
          payment = @order.payments.create!(
          :amount => @order.total,
          :payment_method => @pay_method
          )
          redirect_to checkout_state_path("confirm") and return
        end
      end

      if @order.update_from_params(params, permitted_checkout_attributes)
        persist_user_address
        unless @order.next
          flash[:error] = @order.errors.full_messages.join("\n")
          redirect_to checkout_state_path(@order.state) and return
        end

        if @order.completed?
          session[:order_id] = nil
          flash.notice = Spree.t(:order_processed_successfully)
          flash[:commerce_tracking] = "nothing special"
          redirect_to completion_route
        else
          redirect_to checkout_state_path(@order.state)
        end
      else
        render :edit
      end
    end
  end
end