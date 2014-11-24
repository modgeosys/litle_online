module LitleOnline
  module Transaction
    
    class Response
    attr_accessor :response_code, :message
    
    private
      def find_element_by_name(element_root, name)
         element_root.each_element() do |element| 
           tag = element.expanded_name
           return element if (tag == name)
         end
         return nil
      end
      
    protected
      @@root_attr_keys = {
	                 'response' => 'root_response',
			 'version' => 'root_version',
			 'message' => 'root_message'
			 }
			 
      attr_accessor :id, :report_group, :customer_id, :transaction_id, :order_id, :response_time
      @@common_attr_keys = { 
                             'id' => 'id',
			     'reportGroup' => 'report_group',
			     'customerId' => 'customer_id'
			   }

      @@common_element_keys = {
	                      'litleTxnId' => 'transaction_id',
			      'orderId' => 'order_id',
			      'message' => 'root_message',
			      'response' => 'response_code',
			      'responseTime' => 'response_time',
			      'message' => 'message'
			 }
			 
      @@response_codes = {
                           '000' => 'Approved',
			   '100' => 'Processing Network Unavailable',
			   '101' => 'Issuer Unavailable',
			   '102' => 'Re‐submit Transaction',
			   '110' => 'Insufficient Funds',
			   '111' => 'Authorization amount has already been depleted',
			   '120' => 'Call Issuer',
			   '121' => 'Call AMEX',
			   '122' => 'Call Diners Club',
			   '123' => 'Call Discover',
			   '124' => 'Call JBS',
			   '125' => 'Call Visa/MasterCard',
			   '126' => 'Call Issuer ‐ Update Cardholder Data',
			   '127' => 'Exceeds Approval Amount Limit',
			   '130' => 'Call Indicated Number',
			   '140' => 'Update Cardholder Data',
			   '191' => 'The merchant is not registered in the update program',
			   '301' => 'Invalid Account Number',
			   '302' => 'Account Number Does Not Match Payment Type',
			   '303' => 'Pick Up Card',
			   '304' => 'Lost/Stolen Card',
			   '305' => 'Expired Card',
			   '306' => 'Authorization has expired; no need to reverse',
			   '307' => 'Restricted Card',
			   '308' => 'Restricted Card ‐ Chargeback',
			   '310' => 'Invalid track data',
			   '311' => 'Deposit is already referenced by a chargeback',
			   '320' => 'Invalid Expiration Date',
			   '321' => 'Invalid Merchant',
			   '322' => 'Invalid Transaction',
			   '323' => 'No such issuer',
			   '324' => 'Invalid Pin',
			   '325' => 'Transaction not allowed at terminal',
			   '326' => 'Exceeds number of PIN entries',
			   '327' => 'Cardholder transaction not permitted',
			   '328' => 'Cardholder requested that recurring or installment payment be stopped',
			   '330' => 'Invalid Payment Type',
			   '335' => 'This method of payment does not support authorization reversals',
			   '340' => 'Invalid Amount',
			   '346' => 'Invalid billing descriptor prefix',
			   '349' => 'Do Not Honor',
			   '350' => 'Generic Decline',
			   '351' => 'Decline ‐ Request Positive ID',
			   '352' => 'Decline CVV2/CID Fail',
			   '353' => 'Merchant requested decline due to AVS result',
			   '354' => '3‐D Secure transaction not supported by merchant',
			   '355' => 'Failed velocity check',
			   '356' => 'Invalid purchase level III, the transaction contained bad or missing data',
			   '360' => 'No transaction found with specified litleTxnId',
			   '361' => 'Transaction found but already referenced by another deposit',
			   '362' => 'Transaction Not Voided ‐ Already Settled',
			   '365' => 'Total credit amount exceeds capture amount',
			   '370' => 'Internal System Error ‐ Call Litle',
			   '400' => 'No Email Notification was sent for the transaction',
			   '401' => 'Invalid Email Address',
			   '500' => 'The account number was changed',
			   '501' => 'The account was closed',
			   '502' => 'The expiration date was changed',
			   '503' => 'The issuing bank does not participate in the update program',
			   '504' => 'Contact the cardholder for updated information',
			   '505' => 'No match found',
			   '506' => 'No changes found',
			   '601' => 'Soft Decline ‐ Primary Funding Source Failed',
			   '602' => 'Soft Decline ‐ Buyer has alternate funding source',
			   '610' => 'Hard Decline ‐ Invalid Billing Agreement Id',
			   '611' => 'Hard Decline ‐ Primary Funding Source Failed',
			   '612' => 'Hard Decline ‐ Issue with Paypal Account',
			   '701' => 'Under 18 years old',
			   '702' => 'Bill to outside USA',
			   '703' => 'Bill to address is not equal to ship to address',
			   '704' => 'Declined, foreign currency, must be USD',
			   '705' => 'On negative file',
			   '706' => 'Blocked agreement',
			   '707' => 'Insufficient buying power',
			   '708' => 'Invalid Data',
			   '709' => 'Invalid Data ‐ data elements missing',
			   '710' => 'Invalid Data ‐ data format error',
			   '711' => 'Invalid Data ‐ Invalid T&C version',
			   '712' => 'Duplicate transaction',
			   '713' => 'Verify billing address',
			   '714' => 'Inactive Account',
			   '716' => 'Invalid Auth',
			   '717' => 'Authorization already exists for the order'
			 }
      end 			   
      
      def initialize(response_xml)
        xml_response_doc = REXML::Document.new(response_xml)
	@root_element = xml_response_doc.root
	@root_element.attributes.each_attribute do |attr|
	  key = @@root_attr_keys[attr.expanded_name]
	  unless key.nil?
            send("#{key}=",attr.value)
	  end
	end
	@success = false
	@message = nil
	@details = Hash.new
	self.parse
      end
      
      
      def parse
	all_element_keys = Hash.new
	all_element_keys.merge!(@@common_element_keys)
	all_element_keys.merge!(@extra_element_keys)
	main_element = find_element_by_name(@root_element, @main_xml_context)
#        puts @root_element
	return if main_element.nil?
	main_element.attributes.each_attribute do |attr|
	  key = @@common_attr_keys[attr.expanded_name]
	  unless key.nil?
            send("#{key}=",attr.value)
	  end
	end
	main_element.each_element do |element|
	  key = all_element_keys[element.expanded_name]
	  unless key.nil?
	    if element.has_elements?
	      send("#{key}=", element)
	    else
              send("#{key}=",element.text)
	    end
	  end
	end
      end
      
    public
      attr_accessor :root_response, :root_version, :root_message
      attr_accessor :id, :report_group, :customer_id, :transaction_id, :order_id, :response_code, :response_time, :message

      def attribute(key)
        return self.instance_variable_get("@"+key)
      end
      
      def approved?
        return true if @response_code == '000'
      end
      
      def error
        return "Unknown Error" if @@response_codes[@response_code].nil?
        return @@response_codes[@response_code]
      end

    end
    

    class ResponseSubElement
      protected
      @attribute_keys = {}
      @element_keys = {}
      
      def initialize
      end
      
      public
      def initialize(element)
        @main_element = element
	self.parse
      end
      
      def parse
	@main_element.attributes.each_attribute do |attr|
	  key = @attribute_keys[attr.expanded_name]
	  unless key.nil?
            send("#{key}=",attr.value)
	  end
	end
	@main_element.each_element do |element|
	  key = @element_keys[element.expanded_name]
	  unless key.nil?
            send("#{key}=",element.text)
	  end
	end
      end
    end


    # This class is used to parse Fraud Result response sub element
    # received from the gateway.
    # It takes XML string as input.
    #
    # Different levels of XML atributes can then be accessed as variables.
    
    class FraudResultSub < ResponseSubElement
      protected
      @@avs_response_codes = {
                          '00' => '5-Digit zip and address match',
			  '01' => '9-Digit zip and address match',
			  '02' => 'Postal code and address match',
			  '10' => '5-Digit zip matches, address does not match',
			  '11' => '9-Digit zip matches, address does not match',
			  '12' => 'Zip does not match, address matches',
			  '13' => 'Postal code does not match, address matches',
			  '14' => 'Postal code matches, address not verified',
			  '20' => 'Neither zip nor address mat',
			  '30' => 'AVS service not supported by issuer',
			  '31' => 'AVS system not available',
			  '32' => 'Address unavailable',
			  '33' => 'General error',
			  '34' => 'AVS not performed',
			  '40' => 'Address failed Litle & Co. edit checks'
			 }

    
      @@cvv_response_codes = {
                          'M' => 'Match',
			  'N' => 'No Match',
			  'P' => 'Not Processed',
			  'S' => 'CVV2/CVC2/CID should be on the card but the merchant has indicated CVV2/CVC2/CID is not present',
			  'U' => 'Issuer is not certified for CVV2/CVC2/CID processing'
			 }

      @@auth_response_codes = {
                          'B' => 'CAVV passed verification but no liability shift because a) ECI was not 5 or 6 or b) the card type is an excluded (e.g., Commercial Card)',
			  '0' => 'CAVV data field not properly formatted; verification cannot be performed.',
			  '6' => 'CAVV not verified because Issuer has requested no verification. VisaNet processes as if CAVV is valid.',
			  '1' => 'CAVV failed verification',
			  '2' => 'CAVV passed verification',
			  'D' => 'Issuer elected to return CAVV verification results and Field 44.13 blank. Value is set by VisaNet; means CAVV Results are valid.',
			  '3' => 'CAVV passed verification',
			  '4' => 'CAVV failed verification',
			  '7' => 'CAVV failed verification',
			  '8' => 'CAVV passed verification',
			  '9' => 'CAVV failed verification; Visa generated CAVV because Issuer ACS was not available',
			  'A' => 'CAVV passed verification; Visa generated CAVV because Issuer ACS was not available',
			  'C' => 'Issuer elected to return CAVV verification results and Field 44.13 blank. Value is set by VisaNet; means CAVV Results are valid'
			}




      public
      attr_accessor :avs_result, :validation_result, :authentication_result
      
      def parse
        @attribute_keys = {}
        @element_keys = {
    			   'avsResult' => 'avs_result',
			   'cardValidationResult' => 'validation_result',
			   'authentication_result' => 'authentication_result'
	  	         }
	super
      end

      def avs_message
        return "Unknown Response Code" if @@avs_response_codes[@avs_result].nil?
        return @@avs_response_codes[@avs_result]
      end
        
      def cvv_message
	return "Check was not done for an unspecified reason" if @validation_result.nil?
        return "Unknown Response Core" if @@cvv_response_codes[@validation_result].nil?
        return @@cvv_response_codes[@validation_result]
      end
      
      def auth_message
	return "Standard ecommerce or non ecommerce transactions, not an authentication or attempted authentication. CAVV not present" if authentication_result.nil?
        return "Unknown Response Core" if @@auth_response_codes[@authenticaton_result].nil?
        return @@auth_response_codes[@authentication_result]
      end
    end

    
    # This class is used to parse Bill Me Later response sub element
    # received from the gateway.
    # It takes XML string as input.
    #
    # Different levels of XML atributes can then be accessed as variables.
    
    class BillMeLaterResultSub < ResponseSubElement
      protected

      public
      attr_accessor :merchant_id, :offer_code, :credit_line, :address_indicator

      def parse
        @attribute_keys = {}
        @element_keys = {
      			   'bmlMerchantId' => 'merchant_id',
			   'promotionalOfferCode' => 'offer_code',
			   'creditLine' => 'credit_line',
			   'addressIndicator' => 'address_indicator'
		         }
	super
      end		 
    end



    # This class is used to parse AccountInfomration response sub element
    # received from the gateway.
    # It takes XML string as input.
    #
    # Different levels of XML atributes can then be accessed as variables.
    
    class AccountInformationResultSub < ResponseSubElement
      protected

      public
      attr_accessor :type, :number
      
      def parse
        @attribute_keys = {}
        @element_keys = {
    			   'type' => 'type',
			   'number' => 'number',
		         }
	super
      end
    end
    
    

    # This class is used to parse Authorization response
    # received from the gateway.
    # It takes XML string as input.
    #
    # Different levels of XML atributes can then be accessed as variables.

    class AuthorizationResponse < Response
      attr_accessor :post_date, :auth_code, :account_info_result, :fraud_result, :bill_me_later_result
      
      protected
      def parse
        @main_xml_context = 'authorizationResponse'
        @extra_element_keys = {
      	                      'postDate' => 'post_date',
			      'authCode' => 'auth_code',
			      'accountInformation' => 'account_info_result',
			      'fraudResult' => 'fraud_result',
			      'billMeLaterResponseData' => 'bill_me_later_result'
			     }
	super
      end
      
      def fraud_result=(element)
	@fraud_result = FraudResultSub.new(element)
      end

      def account_info_result=(element)
        @account_info_result = AccountInformationResultSub.new(element)
      end
      
      def bill_me_later_result=(element)
	@bill_me_later_result = BillMeLaterResultSub.new(element)
      end
      
    end
    

    # This class is used to parse Authorization Reversal response
    # received from the gateway.
    # It takes XML string as input.
    #
    # Different levels of XML atributes can then be accessed as variables.
    
    class AuthorizationReversalResponse < Response
      attr_accessor :post_date
      
      protected
      def parse
        @main_xml_context = 'authReversalResponse'
        @extra_element_keys = {}
	super
      end
      
    end



    # This class is used to parse Authorization response for AVSOnly request
    # received from the gateway.
    # It takes XML string as input.
    #
    # Different levels of XML atributes can then be accessed as variables.

    class AVSOnlyResponse < Response
      attr_accessor :post_date, :auth_code, :account_info_result, :fraud_result, :bill_me_later_result
      
      protected
      def parse
        @main_xml_context = 'authorizationResponse'
        @extra_element_keys = {
			      'authCode' => 'auth_code',
			      'fraudResult' => 'fraud_result',
			     }
	super
      end
      
      def fraud_result=(element)
	@fraud_result = FraudResultSub.new(element)
      end
    end



    # This class is used to parse Capture response
    # received from the gateway.
    # It takes XML string as input.
    #
    # Different levels of XML atributes can then be accessed as variables.
    
    class CaptureResponse < Response
      attr_accessor :post_date, :auth_code, :fraud_result
      
      
      protected
      def parse
        @main_xml_context = 'captureResponse'
        @extra_element_keys = {
      	                      'postDate' => 'post_date',
			     }
	super
      end
      
    end


    # This class is used to parse Sale response
    # received from the gateway.
    # It takes XML string as input.
    #
    # Different levels of XML atributes can then be accessed as variables.
    
    class SaleResponse < Response
      attr_accessor :post_date, :auth_code, :account_info_result, :fraud_result, :bill_me_later_result
      
      
      
      protected
      def parse
        @main_xml_context = 'saleResponse'
        @extra_element_keys = {
      	                      'postDate' => 'post_date',
			      'authCode' => 'auth_code',
			      'accountInformation' => 'account_info_result',
			      'fraudResult' => 'fraud_result',
			      'billMeLaterResponseData' => 'bill_me_later_result'
			     }
	super
      end
      
      def fraud_result=(element)
	@fraud_result = FraudResultSub.new(element)
      end

      def account_info_result=(element)
        @account_info_result = AccountInformationResultSub.new(element)
      end
      
      def bill_me_later_result=(element)
	@bill_me_later_result = BillMeLaterResultSub.new(element)
      end
      
    end
    
    # This class is used to parse Credit response
    # received from the gateway.
    # It takes XML string as input.
    #
    # Different levels of XML atributes can then be accessed as variables.
    
    class CreditResponse < Response
      attr_accessor :post_date
      
      protected
      def parse
        @main_xml_context = 'creditResponse'
        @extra_element_keys = {
      	                      'postDate' => 'post_date',
			     }
	super
      end
      
    end


    # This class is used to parse Void response
    # received from the gateway.
    # It takes XML string as input.
    #
    # Different levels of XML atributes can then be accessed as variables.
    
    class VoidResponse < Response
      attr_accessor :post_date
      
      protected
      def parse
        @main_xml_context = 'voidResponse'
        @extra_element_keys = {
      	                      'postDate' => 'post_date',
			     }
	super
      end
      
    end


  end
end
