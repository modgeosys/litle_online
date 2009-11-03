module LitleOnline
  class CardholderAuth < General
  public
    attr_accessor :auth_value, :token, :transaction_id, :customer_ip, :auth_by_merchant, :auth_source

  protected    
    def validate
      raise_validation_error "Required attribute auth_value is empty" if @auth_value.nil?
      raise_validation_error "Invalid customer_ip in: #{@customer_ip}" unless @customer_ip =~ /^(\d{1,3}\.){3}\d{1,3}$/ || @custome_ip.nil?
    end
      

    def generate
      @template='cardholder_auth.rxml'
	
      @fields = { 
	    'authenticationValue' => @auth_value,
	    'authenticationTransactionId' => @transaction_id,
	    'customerIpAddress' => @customer_ip,
	    'authenticatedByMerchant' => @auth_by_merchant,
	    'authorizationSourcePlatform' => @auth_source
	    
      }
      construct_xml(@fields)
    end
  end
  
end
