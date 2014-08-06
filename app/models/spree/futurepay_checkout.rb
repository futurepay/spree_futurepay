module Spree
  class FuturepayCheckout < ActiveRecord::Base
    
    def actions
      %w{}
    end

    def can_void?(payment)
      false
    end
  end
end
