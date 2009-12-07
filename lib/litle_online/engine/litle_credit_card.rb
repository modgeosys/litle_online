require 'time'

module LitleOnline
  class CreditCard < General
  public
    attr_accessor :number, :month, :year, :type, :validation_number

  
  private
    @@card_type = { 
      'visa'			       => 'VI',
      'master'		       => 'MC',
      'american_express' => 'AX',
      'bill_me_later'		 => 'BL',
      'discover'		     => 'DI',
      'diners_club'      => 'DC',
      'jcb'			         => 'JC'
    }

    def validate_type
      return true unless @@card_type[@type].nil?
    end          
      
    def valid_card_checksum
      digits = ''
      sum = ''
      @number.split().reverse.each_with_index do |num,indx|
        digits += num if indx%2 == 0
        digits += (num.to_i*2).to_s if indx%2 == 1
      end
      digits.split('').inject(0) do |sum,num|
        sum += num.to_i
      end
      sum%10 == 0
    end
	
    def validate_number
      length = @number.size
      case @type
        when 'visa'
          return false unless (length == 13 || length == 16) && @number =~ /^4/
	  
        when 'master'
          return false unless length == 16 && @number =~ /^5[1-5]/
	    
        when 'american_express'
          return false unless length == 15 && @number =~ /^3(4|7)/
	    
        when 'discover'
          return false unless length == 16 && @number =~ /^6(011|5)/
	    
        when 'discover'
          return false unless length == 16 && @number =~ /^6(011|5)/
	    
        when 'jcb'
          return false unless (length == 15 && @number =~/^(2131|1800)/) || (length == 16 && @number =~/^35/)
	    
      end
      return true
    end
      
    def validate_expiration
      return false if (@month < 1 || @month > 12)
      return false if (@year < 9 || @year > 99)
      expTime = Time.parse("#{@month}/#{year}")
      return false if Time.now > expTime
      return true
    end
      
    def validate_cvv
      return true if @validation_number.nil? || @type.nil?
      case @type
        when 'visa'
          return true if @validation_number =~ /^\d\d\d$/
	    
        when 'master'
          return true if @validation_number =~ /^\d\d\d$/
  
        when 'discover'
          return true if @validation_number =~ /^\d\d\d$/

        when 'american_express'
          return true if @validation_number =~ /^\d\d\d\d$/
	  
        else
          return true if @validation_number.nil?
      end
    end
      
    protected    
    def validate
      @type.downcase! unless @type.nil?
      @month = @month.to_i
      @year = @year.to_i
      @year = @year - 2000 if @year > 2000
      raise_validation_error "Invalid credit card type '#{@type}'" unless @type.nil? || validate_type
      raise_validation_error "Invalid credit card number '#{@number}'" unless validate_number
#      raise_validation_error "Invalid expiration: '#{@month}/#{@year}'" unless validate_expiration
      raise_validation_error "Invalid validation number: '#{@validation_number}'" unless validate_cvv
    end
      

    def generate
      @template='credit_card.rxml'
      @month = @month.to_s
      @month = '0' + @month if @month.length < 2
      @year = @year.to_s
      @year = '0' + @year if @year.length < 2
	
	
      @fields = { 
	    'type' => @@card_type[@type], 
	    'number' => @number, 
	    'expDate' => @month + @year, 
	    'cardValidationNum' => @validation_number 
      }
      construct_xml(@fields)
    end
  end
  
end
