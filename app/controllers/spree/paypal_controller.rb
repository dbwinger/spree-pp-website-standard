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
          order.reload # otherwise it might not see the newly added payment
          order.update!
          if order.can_go_to_state?("complete")
            begin
              until order.state == "complete"
                # this is bad and I feel bad
                # not-full-amount payments should be handled differently
                order.next!
                order.update!
                session[:order_id] = nil
              end
            rescue StateMachine::InvalidTransition
              # couldn't transition, order is not paid fully
            end
          end

          flash[:notice] = t('spree.paypal_website_standard.order_processed_successfully')
          flash[:commerce_tracking] = "nothing special"
        end
        redirect_to order_path(current_order)
      end
    end

  end
end
