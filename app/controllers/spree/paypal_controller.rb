module Spree
  class PaypalController < Spree::CheckoutController
    protect_from_forgery :except => [:confirm]
    skip_before_filter :persist_gender
    
    def confirm
      unless current_order
        redirect_to root_path
      else
        order = current_order
        if (order.payment_state == "paid") or (order.payment_state == "credit_owed")
          flash[:notice] = t('spree.paypal_website_standard.payment_received')
          # Unset the order id as it's completed.
          session[:order_id] = nil
        else
          while order.state != "complete"
            order.next
            # Unset the order id as it's completed.
            session[:order_id] = nil
          end
          flash[:notice] = t('spree.paypal_website_standard.order_processed_successfully')
          flash[:commerce_tracking] = "nothing special"
        end
        redirect_to order_path(current_order)
      end
    end
  
  end
end