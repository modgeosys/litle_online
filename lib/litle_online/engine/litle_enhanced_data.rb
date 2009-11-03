module LitleOnline
  class EnhancedData < General
  public
    attr_accessor :customer_reference, :delivery_type, :sales_tax, :tax_exempt, :discount_amount, :shipping_amount, 
    	          :duty_amount, :ship_from_zip, :destination_zip, :destination_country, :invoice_ref_number, :orderDate,
		  :detail_tax, :line_item_data


    def detail_tax=(variables={})
      @detail_tax = Array.new if @detail_tax.nil?
      case variables.class.to_s
        when 'Hash'
          @detail_tax << DetailTax.new(variables)
        
	when 'Array'
	  variables.each do | entry_hash |
	    @detail_tax << DetailTax.new(entry_hash) unless entry_hash.nil?
	  end
      end 
    end
    
    def line_item_data=(variables={})
      @line_item_data = Array.new if @line_item_data.nil?
      case variables.class.to_s
        when 'Hash'
          @line_item_data << LineItemData.new(variables)
        
	when 'Array'
	  variables.each do | entry_hash |
	    @line_item_data << LineItemData.new(entry_hash) unless entry_hash.nil?
	  end
      end 
    end

  protected    
    def validate
    end
      

    def generate
      @template='enhanced_data.rxml'
	
      @fields = { 
	    'customerReference' => @customer_reference,
	    'deliveryType' => @delivery_type,
	    'salesTax' => @sales_tax,
	    'taxExempt' => @tax_exempt,
	    'discountAmount' => @discount_amount,
	    'shippingAmount' => @shipping_amount,
	    'dutyAmount' => @duty_amount,
	    'shipFromPostalCode' => @ship_from_zip,
	    'destinationPostalCode' => @destination_zip,
	    'destinationCountryCode' => @destination_country,
	    'invoiceReferenceNumber' => @invoice_ref_numner,
	    'orderDate' => @order_date
      }
      construct_xml(@fields)
      unless @detail_tax.nil?
        @detail_tax.each do | entry |
	  insert_xml_element(entry.xml_root_element) unless entry.nil?
	end
      end
      unless @line_item_data.nil?
        @line_item_data.each do | entry |
	  insert_xml_element(entry.xml_root_element) unless entry.nil?
	end
      end
      
    end
  end  
  
  
  class DetailTax < General
    public
      attr_accessor :tax_in_total, :tax_amount, :tax_rate, :tax_type, :card_acceptor_tax_id

    protected    
      def validate
#        raise_validation_error "Required attribute merchant_id is empty" if @merchant_id.nil?
      end
      

      def generate
        @template='detail_tax.rxml'
	
        @fields = { 
  	    'taxIncludedInTotal' => @tax_in_total,
	    'taxAmount' => @tax_amount,
	    'taxRate' => @tax_rate,
	    'taxTypeIdentifier' => @tax_type,
	    'cardAcceptorTaxId' => @card_acceptor_tax_id
        }
        construct_xml(@fields)
      end
  end
  

  class LineItemData < General
    public
      attr_accessor :item_seq_number, :item_description, :product_code, :quantity, :measure_unit, :tax_amount,
                    :total, :total_with_tax, :item_discount, :commodity_code, :unit_cost
    

    protected    
      def validate
      end
      

      def generate
        @template='line_item.rxml'
	
        @fields = { 
  	    'itemSequenceNumber' => @item_seq_number,
	    'itemDescription' => @item_description,
	    'productCode' => @product_code,
	    'quantity' => @quantity,
	    'unitOfMeasure' => @measure_unit,
	    'taxAmount' => @tax_amount,
	    'lineItemTotal' => @total,
	    'lineItemTotalWithTax' => @total_with_tax,
	    'itemDiscountAmount' => @item_discount,
	    'commodityCode' => @commodity_code,
	    'unitCost' => @unit_cost
        }
        construct_xml(@fields)
      end
  end

end
