require 'rexml/document'
require 'active_merchant'

LITLE_CARD_TYPE = {'visa'             => 'VI',
                   'master'           => 'MC',
                   'discover'         => 'DI',
                   'american_express' => 'AX',
                   'diners_club'      => 'DC',
                   'jcb'              => 'JCB'}


class ActiveMerchant::Billing::CreditCard
  include ActiveMerchant::Billing::CreditCardMethods
end


module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class LitleGateway < Gateway 
    private
      def convert_creditcard(creditcard)
        return nil if creditcard.nil?
        LitleOnline::CreditCard.new(
                                              :number => creditcard.number,
                                              :month => sprintf("%.2i", creditcard.month),
                                              :year => sprintf("%.4i", creditcard.year)[-2..-1],
                                              :type => litle_card_type(ActiveMerchant::Billing::CreditCard.type?(creditcard.number)),
					                                    :validation_number => creditcard.verification_value
                                            )
      end
      
      def litle_card_type(generic_card_type)
        LITLE_CARD_TYPE[generic_card_type] || 'BL'
      end

      def fill_in_billing_name(options, creditcard)
        unless creditcard.first_name.nil? || creditcard.last_name.nil?
          options[:billing_address] = {} if options[:billing_address].nil?
          options [:billing_address][:name] = creditcard.first_name + " " + creditcard.last_name 
        end
      end
      
      def fill_in_description(options)
        options[:custom_billing] = {} if options[:custom_billing].nil?
	description = options[:description]
	raise "description should start with '#{@litle_gw.username}*'" unless  description =~ /#{@litle_gw.username}\*/
        options [:custom_billing][:descriptor] = options[:description]
      end
      
      def convert_response(result, custom_params={})
        params = {
             :authorization => result.transaction_id,
	     :result => result
	}
        unless result.instance_variable_get(:@fraud_result).nil? || result.fraud_result.nil? 
	  params.merge!({
		     :avs_code => result.fraud_result.avs_result,
		     :avs_result => result.fraud_result.avs_message,
		     :cvv_code => result.fraud_result.validation_result,
		     :cvv_result => result.fraud_result.cvv_message
	 })
	end
        LitleResponse.new(result.approved?, result.message, custom_params, params)
      end
      

      
    public
      def initialize(options = {})
        requires!(options, :merchant_id, :login, :password)
        @options = options
        super
        @litle_gw = LitleOnline::Gateway.new(
	     		            :merchantId => @options[:merchant_id],
				    :username => @options[:login],
				    :password => @options[:password]
        )
      end

      def authorize(money, creditcard, options = {})
        requires!(options, :report_group, :order_id, :order_source)
	litle_cc = convert_creditcard(creditcard)
        fill_in_billing_name(options, creditcard) if options[:billing_address].nil? || options[:billing_address][:name].nil?
        fill_in_description(options) unless options[:description].nil?

        customer_info = LitleOnline::CustomerInfo.new(options[:customer_info]) unless options[:customer_info].nil?
        billing_address = LitleOnline::Address::Billing.new(options[:billing_address]) unless options[:billing_address].nil?
        shipping_address = LitleOnline::Address::Shipping.new(options[:shipping_address]) unless options[:shipping_address].nil?
        paypal = LitleOnline::Paypal.new(options[:paypal]) unless options[:paypal].nil?
        custom_billing = LitleOnline::CustomBilling.new(options[:custom_billing]) unless options[:custom_billing].nil?
        bill_me_later = LitleOnline::BillMeLater.new(options[:bill_me_later]) unless options[:bill_me_later].nil?
        cardholder_auth = LitleOnline::CardholderAuth.new(options[:cardholder_auth]) unless options[:cardholder_auth].nil?
        processing_instructions = LitleOnline::ProcessingInstructions.new(options[:processing_instructions]) unless options[:processing_instructions].nil?
        pos = LitleOnline::POS.new(options[:pos]) unless options[:pos].nil?
        enhanced_data = LitleOnline::EnhancedData.new(options[:enhanced_data]) unless options[:enhanced_data].nil?
	
					    
	result = @litle_gw.authorize(	
			    :report_group => options[:report_group],
			    :customer_id => options[:customer_id],
			    :order_id => options[:order_id],
			    :amount => money.to_s,
			    :order_source => options[:order_source],
			    :customer_info => customer_info,
			    :billing_address => billing_address,
			    :shipping_address => shipping_address,
			    :paypal => paypal,
     		            :credit_card => litle_cc,
			    :custom_billing => custom_billing,
			    :bill_me_later => bill_me_later,
			    :cardholder_auth => cardholder_auth,
    		            :processing_instructions => processing_instructions,
			    :pos => pos,
			    :enhanced_data => enhanced_data
			    )
	
	custom_params = { 
	             :auth_code => result.auth_code
		   }
        
	convert_response(result, custom_params)
      end


      def authorization_reversal(money, authorization, options = {})
        requires!(options, :report_group)
	
        result = @litle_gw.auth_reversal(
			    :report_group => options[:report_group],
			    :transaction_id => authorization,
			    :amount => money.to_s
			    )
					    
	convert_response(result)
      end

      
      
      def capture(money, authorization, options = {})
        requires!(options, :report_group)
        enhanced_data = LitleOnline::EnhancedData.new(options[:enhanced_data]) unless options[:enhanced_data].nil?
        processing_instructions = LitleOnline::ProcessingInstructions.new(options[:processing_instructions]) unless options[:processing_instructions].nil?
	
        result = @litle_gw.capture(
			    :report_group => options[:report_group],
			    :customer_id => options[:customer_id],
			    :partial => options[:partial],
			    :transaction_id => authorization,
			    :amount => money.to_s,
    		            :processing_instructions => processing_instructions,
			    :paypal_complete => options[:paypal_complete]
			    )
					    
	convert_response(result)
      end

      def purchase(money, creditcard, options = {})
        requires!(options, :report_group, :order_id, :order_source)
	litle_cc = convert_creditcard(creditcard)
        fill_in_billing_name(options, creditcard) if options[:billing_address].nil? || options[:billing_address][:name].nil?
        fill_in_description(options) unless options[:description].nil?

        customer_info = LitleOnline::CustomerInfo.new(options[:customer_info]) unless options[:customer_info].nil?
        billing_address = LitleOnline::Address::Billing.new(options[:billing_address]) unless options[:billing_address].nil?
        shipping_address = LitleOnline::Address::Shipping.new(options[:shipping_address]) unless options[:shipping_address].nil?
        paypal = LitleOnline::Paypal.new(options[:paypal]) unless options[:paypal].nil?
        bill_me_later = LitleOnline::BillMeLater.new(options[:bill_me_later]) unless options[:bill_me_later].nil?
        cardholder_auth = LitleOnline::CardholderAuth.new(options[:cardholder_auth]) unless options[:cardholder_auth].nil?
        custom_billing = LitleOnline::CustomBilling.new(options[:custom_billing]) unless options[:custom_billing].nil?
        enhanced_data = LitleOnline::EnhancedData.new(options[:enhanced_data]) unless options[:enhanced_data].nil?
        processing_instructions = LitleOnline::ProcessingInstructions.new(options[:processing_instructions]) unless options[:processing_instructions].nil?
        pos = LitleOnline::POS.new(options[:pos]) unless options[:pos].nil?
	
					    
	result = @litle_gw.sale(	
			    :report_group => options[:report_group],
			    :customer_id => options[:customer_id],
			    :order_id => options[:order_id],
			    :amount => money.to_s,
			    :order_source => options[:order_source],
			    :customer_info => customer_info,
			    :billing_address => billing_address,
			    :shipping_address => shipping_address,
			    :paypal => paypal,
     		            :credit_card => litle_cc,
			    :custom_billing => custom_billing,
			    :bill_me_later => bill_me_later,
			    :cardholder_auth => cardholder_auth,
    		            :processing_instructions => processing_instructions,
			    :pos => pos,
			    :enhanced_data => enhanced_data,
			    :paypal_complete => options[:paypal_complete]
			    )
	
	custom_params = { 
	             :auth_code => result.auth_code
		   }
        
	convert_response(result, custom_params)
      end


      def credit(money, identification, options = {})
        if identification.respond_to?(:number)
          result = credit_extended(money, identification, options)
        else
          requires!(options, :report_group)
          fill_in_description(options) unless options[:description].nil?
          custom_billing = LitleOnline::CustomBilling.new(options[:custom_billing]) unless options[:custom_billing].nil?
          enhanced_data = LitleOnline::EnhancedData.new(options[:enhanced_data]) unless options[:enhanced_data].nil?
          processing_instructions = LitleOnline::ProcessingInstructions.new(options[:processing_instructions]) unless options[:processing_instructions].nil?
	  
          result = @litle_gw.credit_with_transaction_id(
			      :report_group => options[:report_group],
			      :customer_id => options[:customer_id],
			      :transaction_id => identification,
			      :amount => money.to_s,
			      :custom_billing => custom_billing,
			      :enhanced_data => enhanced_data,
    		              :processing_instructions => processing_instructions
			      )
					    
	  convert_response(result)
        end
      end

                                             
      def credit_extended(money, creditcard, options = {})
        requires!(options, :report_group, :order_id, :order_source)
	litle_cc = convert_creditcard(creditcard)
        fill_in_billing_name(options, creditcard) if options[:billing_address].nil? || options[:billing_address][:name].nil?
        fill_in_description(options) unless options[:description].nil?

        billing_address = LitleOnline::Address::Billing.new(options[:billing_address]) unless options[:billing_address].nil?
        paypal = LitleOnline::Paypal.new(options[:paypal]) unless options[:paypal].nil?
        cardholder_auth = LitleOnline::CardholderAuth.new(options[:cardholder_auth]) unless options[:cardholder_auth].nil?
        custom_billing = LitleOnline::CustomBilling.new(options[:custom_billing]) unless options[:custom_billing].nil?
        bill_me_later = LitleOnline::BillMeLater.new(options[:bill_me_later]) unless options[:bill_me_later].nil?
        enhanced_data = LitleOnline::EnhancedData.new(options[:enhanced_data]) unless options[:enhanced_data].nil?
        processing_instructions = LitleOnline::ProcessingInstructions.new(options[:processing_instructions]) unless options[:processing_instructions].nil?
        pos = LitleOnline::POS.new(options[:pos]) unless options[:pos].nil?
	
					    
	result = @litle_gw.credit(
			    :report_group => options[:report_group],
			    :customer_id => options[:customer_id],
			    :order_id => options[:order_id],
			    :amount => money.to_s,
			    :order_source => options[:order_source],
			    :billing_address => billing_address,
			    :paypal => paypal,
     		            :credit_card => litle_cc,
			    :custom_billing => custom_billing,
			    :bill_me_later => bill_me_later,
			    :cardholder_auth => cardholder_auth,
    		            :processing_instructions => processing_instructions,
			    :pos => pos,
			    :enhanced_data => enhanced_data
			    )
	
	custom_params = { 
	             :order_id => result.order_id
		   }
        
	convert_response(result, custom_params)
      end

      def void(authorization, options = {})
        requires!(options, :report_group)
	
        processing_instructions = LitleOnline::ProcessingInstructions.new(options[:processing_instructions]) unless options[:processing_instructions].nil?
        result = @litle_gw.void(
			    :report_group => options[:report_group],
			    :transaction_id => authorization,
    		            :processing_instructions => processing_instructions
			    )
					    
	convert_response(result)
      end
      
      
    end


    class LitleResponse < Response
      attr_accessor :avs_code, :cvv_code
      
      def initialize(success, message, params = {}, options = {})
        @success, @message, @params = success, message, params.stringify_keys
	@authorization = options[:authorization]
	@fraud_review = options[:fraud_review]
	@avs_code = options[:avs_code]
	@avs_result = options[:avs_result]
	@cvv_code = options[:cvv_code]
	@cvv_result = options[:cvv_result]
	@result = options[:result]
      end
    end

    LitleGateway.class_eval do
      def purchase(money, creditcard, options = {})
        requires!(options, :report_group, :order_id, :order_source)
	litle_cc = convert_creditcard(creditcard)
        fill_in_billing_name(options, creditcard) if options[:billing_address].nil? || options[:billing_address][:name].nil?
        fill_in_description(options) unless options[:description].nil?

        customer_info = LitleOnline::CustomerInfo.new(options[:customer_info]) unless options[:customer_info].nil?
        billing_address = LitleOnline::Address::Billing.new(options[:billing_address]) unless options[:billing_address].nil?
        shipping_address = LitleOnline::Address::Shipping.new(options[:shipping_address]) unless options[:shipping_address].nil?
        paypal = LitleOnline::Paypal.new(options[:paypal]) unless options[:paypal].nil?
        bill_me_later = LitleOnline::BillMeLater.new(options[:bill_me_later]) unless options[:bill_me_later].nil?
        cardholder_auth = LitleOnline::CardholderAuth.new(options[:cardholder_auth]) unless options[:cardholder_auth].nil?
        custom_billing = LitleOnline::CustomBilling.new(options[:custom_billing]) unless options[:custom_billing].nil?
        enhanced_data = LitleOnline::EnhancedData.new(options[:enhanced_data]) unless options[:enhanced_data].nil?
        processing_instructions = LitleOnline::ProcessingInstructions.new(options[:processing_instructions]) unless options[:processing_instructions].nil?
        pos = LitleOnline::POS.new(options[:pos]) unless options[:pos].nil?

	result = @litle_gw.avs_only(
			    :report_group => options[:report_group],
			    :customer_id => options[:customer_id],
			    :order_id => options[:order_id],
			    :amount => money.to_s,
			    :order_source => options[:order_source],
			    :billing_address => billing_address,
     		            :credit_card => litle_cc,
			    :cardholder_auth => cardholder_auth,
    		            :processing_instructions => processing_instructions,
			    :pos => pos
			)


	custom_params = { 
	             :auth_code => result.auth_code
		   }

	if result.fraud_result && [12, 13, 20].include?(result.fraud_result.avs_result.to_i)
	  result.response_code = "353" 
	  result.message = "Merchant requested decline due to AVS result"
	  return convert_response(result, custom_params)
	end

	result = @litle_gw.sale(	
			    :report_group => options[:report_group],
			    :customer_id => options[:customer_id],
			    :order_id => options[:order_id],
			    :amount => money.to_s,
			    :order_source => options[:order_source],
			    :customer_info => customer_info,
			    :billing_address => billing_address,
			    :shipping_address => shipping_address,
			    :paypal => paypal,
     		            :credit_card => litle_cc,
			    :custom_billing => custom_billing,
			    :bill_me_later => bill_me_later,
			    :cardholder_auth => cardholder_auth,
    		            :processing_instructions => processing_instructions,
			    :pos => pos,
			    :enhanced_data => enhanced_data,
			    :paypal_complete => options[:paypal_complete]
			    )
	
	convert_response(result, custom_params)
      end
    end

  end
end

