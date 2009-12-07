#!/bin/env ruby

# loads the local "gem" code"
#
# for production this would change to
# 
require 'rubygems'
require 'litle_online'

#require File.expand_path(::File.join(::File.dirname(__FILE__), "..", 'lib', 'litle_online.rb'))

emacs_trace do 

  script_args = CkuruTools::ArgsProcessor.new(:args => ["merchant_id+",
                                                        "login+",
                                                        "password+"]).parse # ckuru-tools/lib/args.rb
  
  # Testing authorization and capture.
  puts
  puts
  puts "Testing authorization and capture requests"
  
  # Create a new credit card instance. Credit card object includes a name in cyrilic,
  # to test UTF-8 compatibility
  cc_visa_1 = ActiveMerchant::Billing::CreditCard.new(
                                                         :first_name => 'Евгений',
							 :last_name => 'Онегин',
                                                         :number => '4457010000000009',
                                                         :month => '01',
                                                         :year => '2009',
                                                         :type => 'visa',
							 :verification_value => '349'
							)


  # Initialize Litle Gateway
  litle_gw = ActiveMerchant::Billing::LitleGateway.new(script_args)

  # setup some options, only report_group and order_id are required.
  options = {
                 :report_group => 'Test Authorizations',
		 :customer_id => 'Test Customer',
                 :order_id => '1',
		 :order_source => 'ecommerce',
		 :billing_address => {
					:address1 => "1 Main St.",
					:city => "Burlington",
					:state => "MA",
					:zip => "01803-3747",
					:country => "US",
					:email => "test@test.com"
				     },
		 :description => 'WDI*Testing 123'

	    }

  # Submit Authorization request.
  puts
  puts "Submitting test Authorization"
  response = litle_gw.authorize(10010, cc_visa_1, options)

  # Evaluate the results
  if response.success?
    puts
    puts "Authorization approved with transaction id: #{response.authorization}. Fraud review:"
    puts "AVS: #{response.avs_code} = #{response.avs_result}"
    puts "CVV: #{response.cvv_code} = #{response.cvv_result}"

    # Set up capture options.
    options = {
                 :report_group => 'Test Captures',
		 :customer_id => 'Test Customer'
	      }
    # Submit Capture request
    puts
    puts "Submitting test capture"
    response = litle_gw.capture(10010, response.authorization, options)
    if response.success?
      puts
      puts "Capture approved with transaction id: #{response.authorization}."
    end
  else
    puts
    puts "Authorization failed with message: #{response.message}"
  end



  # Testing purchase(sale) and credit requests
  puts 
  puts
  puts "Testing purchase and credit requests"
  
  # set up credit card
  cc_master_1 = ActiveMerchant::Billing::CreditCard.new(
                                                         :first_name => 'Mike',
							 :last_name => 'Hammer',
                                                         :number => '5112010000000003',
                                                         :month => '02',
                                                         :year => '2009',
                                                         :type => 'master',
							 :verification_value => '261'
							)
  # setup purchase options
  options = {
                 :report_group => 'Test Purchase',
		 :customer_id => 'Test Customer',
                 :order_id => '2',
		 :order_source => 'ecommerce',
		 :billing_address => {
					:address1 => "2 Main St.",
					:address2 => "Apt. 222",
					:city => "Riverside",
					:state => "RI",
					:zip => "02915",
					:country => "US",
					:email => "test@test.com"
				     },
		 :description => 'WDI*Testing 123'
	    }

  #submit puchase (sale) request.
  puts
  puts "Submitting purchase request"
  response = litle_gw.purchase(20020, cc_master_1, options)

  if response.success?
    puts
    puts "Purchase approved with transaction id: #{response.authorization}. Fraud review:"
    puts "AVS: #{response.avs_code} = #{response.avs_result}"
    puts "CVV: #{response.cvv_code} = #{response.cvv_result}"
    
    # set up credit options
    options = {
                 :report_group => 'Test Credit',
		 :customer_id => 'Test Customer'
	      }
	      
    # submit credit request. This is a basic credit request that work with authorization number (transaction id)
    puts
    puts "Submitting credit request"
    response = litle_gw.credit(20020, response.authorization, options)
    if response.success?
      puts
      puts "Credit transaction approved with transaction id: #{response.authorization}."
    else
      puts
      puts "Credit has failed with message: #{response.message}"
    end
    
  else
    puts
    puts "Purchase failed with message: #{response.message}"
  end


  #Testing authorization and authorization reversal requests.
  puts
  puts
  puts "Testing authorization and authorization reversal requests"
  # set up credit card
  cc_discover_1 = ActiveMerchant::Billing::CreditCard.new(
                                                         :first_name => 'Eileen',
							 :last_name => 'Jones',
                                                         :number => '6011010000000003',
                                                         :month => '03',
                                                         :year => '2009',
                                                         :type => 'discover',
							 :verification_value => '758'
							)
 
  # set up authorization options
  options = {
                 :report_group => 'Test Authorizations',
		 :customer_id => 'Test Customer',
                 :order_id => '3',
		 :order_source => 'ecommerce',
		 :description => 'WDI*Testing 123',
		 :billing_address => {
					:address1 => "3 Main St.",
					:city => "Bloomfield",
					:state => "CT",
					:zip => "06002",
					:country => "US",
					:email => "test@test.com"
				     }
	    }
  # submit authorization request
  puts
  puts "Sumbitting authorization request"
  response = litle_gw.authorize(30030, cc_discover_1, options)

  if response.success?
    puts
    puts "Authorization approved with transaction id: #{response.authorization}. Fraud review:"
    puts "AVS: #{response.avs_code} = #{response.avs_result}"
    puts "CVV: #{response.cvv_code} = #{response.cvv_result}"

    # set up authorization reversal options
    options = {
                 :report_group => 'Test Auth Reversal',
	      }
    # submit authorization reversal request
    puts
    puts "Submitting authorization reversal request"
    response = litle_gw.authorization_reversal(30030, response.authorization, options)
    if response.success?
      puts
      puts "Authorization has been reversed with transaction id: #{response.authorization}."
    else
      puts
      puts "Authorization reversal has failed with message: #{response.message}"
    end
  else
    puts
    puts "Authorization failed with message: #{response.message}"
  end

  
  # Another purchase request
  puts
  puts
  puts "Testing another purchase"
  cc_amex_1 = ActiveMerchant::Billing::CreditCard.new(
                                                         :first_name => 'Bob',
							 :last_name => 'Black',
                                                         :number => '375001000000005',
                                                         :month => '04',
                                                         :year => '2009',
                                                         :type => 'american_express'
							)

  options = {
                 :report_group => 'Test Purchase',
		 :customer_id => 'Test Customer',
                 :order_id => '4',
		 :order_source => 'ecommerce',
		 :billing_address => {
					:address1 => "4 Main St.",
					:city => "Laurel",
					:state => "MD",
					:zip => "20708",
					:country => "US",
					:email => "test@test.com"
				     },
		 :description => 'WDI*Testing 123'
	    }

  response = litle_gw.purchase(40040, cc_amex_1, options)

  if response.success?
    puts
    puts "Purchase approved with transaction id: #{response.authorization}. Fraud review:"
    puts "AVS: #{response.avs_code} = #{response.avs_result}"
    puts "CVV: #{response.cvv_code} = #{response.cvv_result}"
  else
    puts
    puts "Purchase failed with message: #{response.message}"
  end


  # Testing credit and void requests
  # In this case credit_extended method is used allowing credit requests for transactions
  # completed outside of Litle system. This request does not require a Litle transaction ID
  # and can be used directly against a credit card.
  
  # set up Credit options.
  options = {
                 :report_group => 'Test Credit',
		 :customer_id => 'Test Customer',
                 :order_id => '4',
		 :order_source => 'ecommerce',
		 :billing_address => {
					:address1 => "4 Main St.",
					:city => "Laurel",
					:state => "MD",
					:zip => "20708",
					:country => "US",
					:email => "test@test.com"
				     },
		 :description => 'WDI*Testing 123'
	    }

  # submit credit_extended request
  puts
  puts "Submitting credit_extended request"
  response = litle_gw.credit_extended(40040, cc_amex_1, options)

  if response.success?
    puts
    puts "Credit approved with transaction id: #{response.authorization}."
    
    puts
    puts "Testing Void request against the last Credit(extended) transaction"
    # set up void options
    options = {
                 :report_group => 'Test Void',
	      }
    # submit void request
    puts
    puts "Submitting void request"
    response = litle_gw.void(response.authorization, options)
    if response.success?
      puts
      puts "Credit has been voided with transaction id: #{response.authorization}."
    else
      puts
      puts "Voiding of credit has failed with message: #{response.message}"
    end
  else
    puts
    puts "Credit failed with message: #{response.message}"
  end

end

4
