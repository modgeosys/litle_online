module LitleOnline
  class ProcessingInstructions < General
  public
    attr_accessor :no_velocity_check

  protected    
    def validate
    end
      

    def generate
      @template='processing_instructions.rxml'
	
	
      @fields = { 
	    'bypassVelocityCheck' => @no_velocity_check
      }
      construct_xml(@fields)
    end
  end
  
end
