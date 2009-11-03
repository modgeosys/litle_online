module LitleOnline
  class Paypal < General
  public
    attr_accessor :payer_id, :token, :transaction_id

  protected    
    def validate
      raise_validation_error "Required attribute payer_id is empty" if @payer_id.nil?
      raise_validation_error "Required attribute transaction_id is empty" if @transaction_id.nil?
    end
      

    def generate
      @template='paypal.rxml'
	
	
      @fields = { 
	    'payerId' => @payer_id, 
	    'token' => @token, 
	    'transactionId' => @transaction_id, 
      }
      construct_xml(@fields)
    end
  end
  
end
