module LitleOnline
  class CustomBilling < General
  public
    attr_accessor :phone, :city, :descriptor

  protected    
    def validate
    end
      

    def generate
      @template='custom_billing.rxml'
	
	
      @fields = { 
	    'phone' => @phone,
	    'city' => @city,
	    'descriptor' => @descriptor
      }
      construct_xml(@fields)
    end
  end
  
end
