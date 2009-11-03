module LitleOnline
  class CustomerInfo < General
  public
    attr_accessor :ssn, :dob, :registration_date, :customer_type, :income_amount, :income_currency,
                  :employer_name, :work_phone, :residence_status, :years_at_residence, :years_at_employer

  protected    
    def validate
    end

    def generate
      @template='customer_info.rxml'

      @fields = { 
	    'ssn' => @ssn,
	    'dob' => @dob,
	    'customerRegistrationDate' => @registration_date,
	    'customerType' => @customer_type,
	    'incomeAmount' => @income_amount,
	    'incomeCurrency' => @income_currency,
	    'employerName' => @employer_name,
	    'customerWorkTelephone' => @work_phone,
	    'residenceStatus' => @residence_status,
	    'yearsAtResidence' => @years_at_residence,
	    'yearsAtEmployer' => @years_at_employer
      }
      construct_xml(@fields)
    end
  end
  
end
