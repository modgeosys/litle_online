module LitleOnline
  module Address
    class General < LitleOnline::General
    private
      attr_accessor :name, :address1, :address2, :address3, :city, :state, :zip, :country, :email, :phone
      @@country_codes = ["USA", "AF", "AX", "AL", "DZ", "AS", "AD", "AO", "AI", "AQ", "AG", "AR", "AM",
                         "AW", "AU", "AT", "AZ", "BS", "BH", "BD", "BB", "BY", "BE", "BZ", "BJ", "BM",
			 "BT", "BO", "BA", "BW", "BV", "BR", "IO", "BN", "BG", "BF", "BI", "KH", "CM",
			 "CA", "CV", "KY", "CF", "TD", "CL", "CN", "CX", "CC", "CO", "KM", "CG", "CD",
			 "CK", "CR", "CI", "HR", "CU", "CY", "CZ", "DK", "DJ", "DM", "DO", "TL", "EC",
			 "EG", "SV", "GQ", "ER", "EE", "ET", "FK", "FO", "FJ", "FI", "FR", "GF", "PF",
			 "TF", "GA", "GM", "GE", "DE", "GH", "GI", "GR", "GL", "GD", "GP", "GU", "GT",
			 "GG", "GN", "GW", "GY", "HT", "HM", "HN", "HK", "HU", "IS", "IN", "ID", "IR",
			 "IQ", "IE", "IM", "IL", "IT", "JM", "JP", "JE", "JO", "KZ", "KE", "KI", "KP",
			 "KR", "KW", "KG", "LA", "LV", "LB", "LS", "LR", "LY", "LI", "LT", "LU", "MO",
			 "MK", "MG", "MW", "MY", "MV", "ML", "MT", "MH", "MQ", "MR", "MU", "YT", "MX",
			 "FM", "MD", "MC", "MN", "MS", "MA", "MZ", "MM", "NA", "NR", "NP", "NL", "AN",
			 "NC", "NZ", "NI", "NE", "NG", "NU", "NF", "MP", "NO", "OM", "PK", "PW", "PS",
			 "PA", "PG", "PY", "PE", "PH", "PN", "PL", "PT", "PR", "QA", "RE", "RO", "RU",
			 "RW", "BL", "KN", "LC", "MF", "VC", "WS", "SM", "ST", "SA", "SN", "SC", "SL",
			 "SG", "SK", "SI", "SB", "SO", "ZA", "GS", "ES", "LK", "SH", "PM", "SD", "SR",
			 "SJ", "SZ", "SE", "CH", "SY", "TW", "TJ", "TZ", "TH", "TG", "TK", "TO", "TT",
			 "TN", "TR", "TM", "TC", "TV", "UG", "UA", "AE", "GB", "US", "UM", "UY", "UZ",
			 "VU", "VA", "VE", "VN", "VG", "VI", "WF", "EH", "YE", "ZM", "ZW", "RS", "ME"]


      
    protected    
      def validate
        raise_validation_error "Name entry is too long in '#{@name}'" unless @name.nil? ||  @name.length < 100
        raise_validation_error "Address entry is too long in '#{@address1}'" unless  @address1.nil? || @address1.length < 35
        raise_validation_error "Address entry is too long in '#{@address2}'" unless @address2.nil? ||  @address2.length < 35
        raise_validation_error "Address entry is too long in '#{@address3}'" unless @address4.nil? ||  @address3.length < 35
        raise_validation_error "Name of the city is too long in '#{@city}'" unless @city.nil? || @city.length < 35
        raise_validation_error "Name of the state is too long in '#{@city}'" unless  @state.nil? || @state.length < 30
        raise_validation_error "Zip code is too long in '#{@city}'" unless @zip.nil? || @zip.length < 20
        raise_validation_error "Name of the country is too long in '#{@country}'" unless @country.nil? ||  @country.length < 20
        raise_validation_error "Invalid country code: '#{@country}'. Valid codes are: #{@@country_codes.inspect}" unless @country.nil? || @@country_codes.index(@country)
        raise_validation_error "Email address is too long in '#{@email}'" unless @email.nil? || @email.length < 100
        raise_validation_error "Phone is too long in '#{@phone}'" unless @phone.nil? ||  @phone.length < 20
	raise_validation_error "Ivalid Email format in '#{@email}'" unless @email.nil? || @email =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
      end

      def super_generate(template)
        @template=template
		
        @fields = { 
              'name' => @name,
  	      'addressLine1' => @address1,
	      'addressLine2' => @address2,
	      'addressLine3' => @address3,
	      'city' => @city,
	      'state' => @state,
	      'zip' => @zip,
	      'country' => @country,
	      'email' => @email,
	      'phone' => @phone
         }
         construct_xml(@fields)
      end
    end

    class Billing < General
    protected
      def generate
        super_generate('bill_to_address.rxml')
      end
    end
  
    class Shipping < General
    protected
      def generate
        super_generate('ship_to_address.rxml')
      end
    end
  end
end
