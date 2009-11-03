module LitleOnline
  class BillMeLater < General
  public
    attr_accessor :merchant_id, :product_type, :terms, :preapproval_nr, :virtual_auth_key_indicator, :virtual_auth_key_data,
                  :item_category

  protected    
    def validate
      raise_validation_error "Required attribute merchant_id is empty" if @merchant_id.nil?
    end
      

    def generate
      @template='billmelater.rxml'
	
	
      @fields = { 
	    'bmlMerchantId' => @merchant_id,
	    'bmlProductType' => @product_type, 
	    'termsAndConditions' => @terms, 
	    'preapprovalNumber' => @preapproval_nr,
	    'virtualAuthenticationKeyPresenceIndicator' => @virtual_auth_key_indicator,
	    'virtualAuthenticationKeyData' => @virtual_auth_key_data,
	    'itemCategoryCode' => @item_category
      }
      construct_xml(@fields)
    end
  end
  
end
