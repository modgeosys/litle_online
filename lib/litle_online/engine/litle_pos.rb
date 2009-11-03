module LitleOnline
  class POS < General
  public
    attr_accessor :capability, :entry_mode, :cardholder_id

  protected    
    def validate
    end
      

    def generate
      @template='pos.rxml'
	
	
      @fields = { 
	    'capability' => @capability,
	    'entryMode' => @entry_mode,
	    'cardholderId' => @cardholder_id
      }
      construct_xml(@fields)
    end
  end
  
end
