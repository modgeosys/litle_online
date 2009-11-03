module LitleOnline
  module Transaction
    # This class is used to generate an authorization request.
    # It takes a hash of position independant variables
    # defined by attr_accessor method below.
    #
    # Returns REXML::Element object describing <authorization> element.
    
    class Authorization < LitleOnline::General
    private
      attr_accessor :id, :report_group, :customer_id, :order_id, :amount, :order_source, :customer_info, 
                    :billing_address, :shipping_address, :credit_card, :paypal, :custom_billing, :bill_me_later,
		    :cardholder_auth, :processing_instructions, :pos, :enhanced_data

     @@order_sources = [
      '3dsAuthenticated',
      '3dsAttempted',
      'ecommerce',
      'installment',
      'mailorder',
      'recurring',
      'retail',
      'telephone'
    ]

      
    protected
      def validate
        raise_validation_error "Not a vaild order source #{@order_source}" unless @@order_sources.index(@order_source)
        raise_validation_error "Credit card or paypal element required" if @credit_card.nil? && @paypal.nil?
        raise_validation_error "cardholder_auth is required for 3DS transactions" if @cardholder_auth.nil? && 
	  (@order_source == '3dsAuthenticated' || @order_source == '3dsAttempted')
	
      end
    
      def generate
        @template='authorization.rxml'
	@attributes = {
	    'id' => generate_random_id,
	    'reportGroup' => @report_group,
	    'customerId' => @customer_id
	}
	    
	@amount.gsub!(/\./,"")
        @fields = { 
	    'orderId' => @order_id,
	    'amount' => @amount,
	    'orderSource' => @order_source,
        }
        construct_xml(@fields, @attributes)
	insert_xml_element(@customer_info.xml_root_element) unless @customer_info.nil?
	insert_xml_element(@billing_address.xml_root_element) unless @billing_address.nil?
	insert_xml_element(@shipping_address.xml_root_element) unless @shipping_address.nil?
	insert_xml_element(@credit_card.xml_root_element) unless @credit_card.nil?
	insert_xml_element(@paypal.xml_root_element) unless @paypal.nil?
	insert_xml_element(@custom_billing.xml_root_element) unless @custom_billing.nil?
	insert_xml_element(@bill_me_later.xml_root_element) unless @bill_me_later.nil?
	insert_xml_element(@cardholder_auth.xml_root_element) unless @cardholder_auth.nil?
	insert_xml_element(@processing_instructions.xml_root_element) unless @processing_instructions.nil?
	insert_xml_element(@pos.xml_root_element) unless @pos.nil?
	insert_xml_element(@enhanced_data.xml_root_element) unless @enhanced_data.nil?
	self
      end
    end


    # This class is used to generate an Authorization Reversal request.
    # It takes a hash of position independant variables
    # defined by attr_accessor method below.
    #
    # Returns REXML::Element object describing <authReversal> element.
    
    class AuthorizationReversal < LitleOnline::General
    private
      attr_accessor :report_group, :transaction_id, :amount

      
    protected
      def validate
        
      end
    
      def generate
        @template='auth_reversal.rxml'
	@attributes = {
	    'reportGroup' => @report_group,
	}

	@amount.gsub!(/\./,"")
        @fields = { 
	    'litleTxnId' => @transaction_id,
	    'amount' => @amount,
        }
        construct_xml(@fields, @attributes)
	self
      end
    end


    
    # This class is used to generate a caputre request.
    # It takes a hash of position independant variables
    # defined by attr_accessor method below.
    #
    # Returns REXML::Element object describing <capture> element.
    
    class Capture < LitleOnline::General
    private
      attr_accessor :id, :report_group, :customer_id, :partial, :transaction_id, :amount, :enhanced_data, :processing_instructions,
                    :paypal_complete

      
    protected
      def validate
        
      end
    
      def generate
        @template='capture.rxml'
	@partial = 'false' if @partial.nil?
	@paypal_complete = 'false' if @paypal_complete.nil?
	@attributes = {
	    'id' => generate_random_id,
	    'reportGroup' => @report_group,
	    'customerId' => @customer_id,
	    'partial' => @partial
	}

	@amount.gsub!(/\./,"")
        @fields = { 
	    'litleTxnId' => @transaction_id,
	    'amount' => @amount,
        }
        construct_xml(@fields, @attributes)
	insert_xml_element(@enhanced_data.xml_root_element) unless @enhanced_data.nil?
	insert_xml_element(@processing_instructions.xml_root_element) unless @processing_instructions.nil?
	insert_xml_field('payPalOrderComplete', @paypal_complete) if @paypal_complete
	self
      end
    end


    # This class is used to generate an avs only auhtorization request.
    # It takes a hash of position independant variables
    # defined by attr_accessor method below.
    #
    # Returns REXML::Element object describing <authorization> element.
    
    class AVSOnly < LitleOnline::General
    private
      attr_accessor :id, :report_group, :customer_id, :order_id, :amount, :order_source,
                    :billing_address, :credit_card, :cardholder_auth, :processing_instructions,
		    :pos

    protected
      def validate
        raise_validation_error "Credit card element required" if @credit_card.nil?
        raise_validation_error "cardholder_auth is required for 3DS transactions" if @cardholder_auth.nil? && 
	  (@order_source == '3dsAuthenticated' || @order_source == '3dsAttempted')
      end
    
      def generate
        @template='avs_only.rxml'
	@attributes = {
	    'id' => generate_random_id,
	    'reportGroup' => @report_group,
	    'customerId' => @customer_id
	}
	
	@amount = "100"
	    
        @fields = { 
	    'orderId' => @order_id,
	    'amount' => @amount,
	    'orderSource' => @order_source,
        }
        construct_xml(@fields, @attributes)
	insert_xml_element(@billing_address.xml_root_element) unless @billing_address.nil?
	insert_xml_element(@credit_card.xml_root_element)
	insert_xml_element(@cardholder_auth.xml_root_element) unless @cardholder_auth.nil?
	insert_xml_element(@processing_instructions.xml_root_element) unless @processing_instructions.nil?
	insert_xml_element(@pos.xml_root_element) unless @pos.nil?
	self
      end
    end


  
    # This class is used to generate a sale request.
    # It takes a hash of position independant variables
    # defined by attr_accessor method below.
    #
    # Returns REXML::Element object describing <sale> element.
    
    class Sale < LitleOnline::General
    private
      attr_accessor :id, :report_group, :customer_id, :order_id, :amount, :order_source, :customer_info,
                    :billing_address, :shipping_address, :credit_card, :paypal, :bill_me_later,
		    :cardholder_auth, :custom_billing, :enhanced_data, :processing_instructions,
		    :pos, :paypal_complete

    protected
      def validate
        raise_validation_error "Credit card or paypal element required" if @credit_card.nil? && @paypal.nil?
        raise_validation_error "cardholder_auth is required for 3DS transactions" if @cardholder_auth.nil? && 
	  (@order_source == '3dsAuthenticated' || @order_source == '3dsAttempted')
      end
    
      def generate
        @template='sale.rxml'
	@attributes = {
	    'id' => generate_random_id,
	    'reportGroup' => @report_group,
	    'customerId' => @customer_id
	}
	    
	@paypal_complete = 'false' if @paypal_complete.nil?
	@amount.gsub!(/\./,"")

        @fields = { 
	    'orderId' => @order_id,
	    'amount' => @amount,
	    'orderSource' => @order_source,
        }
        construct_xml(@fields, @attributes)
	insert_xml_element(@customer_info.xml_root_element) unless @customer_info.nil?
	insert_xml_element(@billing_address.xml_root_element) unless @billing_address.nil?
	insert_xml_element(@shipping_address.xml_root_element) unless @shipping_address.nil?
	insert_xml_element(@credit_card.xml_root_element)
	insert_xml_element(@paypal.xml_root_element) unless @paypal.nil?
	insert_xml_element(@bill_me_later.xml_root_element) unless @bill_me_later.nil?
	insert_xml_element(@cardholder_auth.xml_root_element) unless @cardholder_auth.nil?
	insert_xml_element(@custom_billing.xml_root_element) unless @custom_billing.nil?
	insert_xml_element(@enhanced_data.xml_root_element) unless @enhanced_data.nil?
	insert_xml_element(@processing_instructions.xml_root_element) unless @processing_instructions.nil?
	insert_xml_element(@pos.xml_root_element) unless @pos.nil?
	insert_xml_field('payPalOrderComplete', @paypal_complete) unless @paypal.nil?
	self
      end
    end
    

    # This class is used to generate a credit request.
    # This class references previous transaction within
    # Litle system.
    #
    # It takes a hash of position independant variables
    # defined by attr_accessor method below.
    #
    # Returns REXML::Element object describing <credit> element.
    
    class CreditWithTransactionId < LitleOnline::General
    private
      attr_accessor :id, :report_group, :customer_id, :transaction_id, :amount, :custom_billing, :enhanced_data, 
                    :processing_instructions

      
    protected
      def validate
        
      end
    
      def generate
        @template='credit_internal.rxml'
	@attributes = {
	    'id' => generate_random_id,
	    'reportGroup' => @report_group,
	    'customerId' => @customer_id
	}
	    
	@amount.gsub!(/\./,"")
        @fields = { 
	    'litleTxnId' => @transaction_id,
	    'amount' => @amount
        }
        construct_xml(@fields, @attributes)
	insert_xml_element(@custom_billing.xml_root_element) unless @custom_billing.nil?
	insert_xml_element(@enhanced_data.xml_root_element) unless @enhanced_data.nil?
	insert_xml_element(@processing_instructions.xml_root_element) unless @processing_instructions.nil?
	self
      end
    end
    

    # This class is used to generate a credit request.
    # This class can be used to initiate credit against
    # order placed outsite Litle system.
    #
    # It takes a hash of position independant variables
    # defined by attr_accessor method below.
    #
    # Returns REXML::Element object describing <credit> element.
    
    class Credit < LitleOnline::General
    private
      attr_accessor :id, :report_group, :customer_id, :order_id, :amount, :order_source, :billing_address, 
                    :credit_card, :paypal, :cardholder_auth, :custom_billing, :bill_me_later, :enhanced_data, 
		    :processing_instructions, :pos

      
    protected
      def validate
        raise_validation_error "Credit card or paypal element required" if @credit_card.nil? && @paypal.nil?
        raise_validation_error "cardholder_auth is required for 3DS transactions" if @cardholder_auth.nil? && 
	  (@order_source == '3dsAuthenticated' || @order_source == '3dsAttempted')
      end
    
      def generate
        @template='credit_external.rxml'
	@attributes = {
	    'id' => generate_random_id,
	    'reportGroup' => @report_group,
	    'customerId' => @customer_id
	}

	@amount.gsub!(/\./,"")
        @fields = { 
	    'orderId' => @order_id,
	    'amount' => @amount,
	    'orderSource' => @order_source
        }
        construct_xml(@fields, @attributes)
	insert_xml_element(@billing_address.xml_root_element) unless @billing_address.nil?
	insert_xml_element(@credit_card.xml_root_element) unless @credit_card.nil?
	insert_xml_element(@paypal.xml_root_element) unless @paypal.nil?
	insert_xml_element(@cardholder_auth.xml_root_element) unless @cardholder_auth.nil?
	insert_xml_element(@custom_billing.xml_root_element) unless @custom_billing.nil?
	insert_xml_element(@bill_me_later.xml_root_element) unless @bill_me_later.nil?
	insert_xml_element(@enhanced_data.xml_root_element) unless @enhanced_data.nil?
	insert_xml_element(@processing_instructions.xml_root_element) unless @processing_instructions.nil?
	insert_xml_element(@pos.xml_root_element) unless @pos.nil?
	self
      end
    end


    # This class is used to generate a Void request.
    # It takes a hash of position independant variables
    # defined by attr_accessor method below.
    #
    # Returns REXML::Element object describing <void> element.
    
    class Void < LitleOnline::General
    private
      attr_accessor :report_group, :transaction_id, :processing_instructions

      
    protected
      def validate
        
      end
    
      def generate
        @template='void.rxml'
	@attributes = {
	    'id' => generate_random_id,
	    'reportGroup' => @report_group
	}
	    
        @fields = { 
	    'litleTxnId' => @transaction_id
        }
        construct_xml(@fields, @attributes)
	insert_xml_element(@processing_instructions.xml_root_element) unless @processing_instructions.nil?
	self
      end
    end


  end
end