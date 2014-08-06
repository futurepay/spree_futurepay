Spree::Admin::PaymentsController.class_eval do
  
  def futurepay_refund
    if request.get?
      if @payment.state == 'refunded'
        redirect_to admin_order_payment_path(@order, @payment)
      end
    elsif request.post?
      response = @payment.payment_method.refund(@payment, params[:refund_amount])
      if response['status'] == "FP_REFUND_SUCCESSFUL"
        flash[:success] = "Refund processed successfully"
        redirect_to admin_order_payments_path(@order)
      else
        flash.now[:error] = "The refund was unsuccessful"+ " (#{response['status']})"
        render
      end
    end
  end
  
end
