require 'net/http'
require 'net/https'
require 'zlib'
require 'ckuru-tools'

module LitleOnline
  class General < CkuruTools::HashInitializerClass
  protected
    def validate
    end
      
    def validate_value(field,type,extra=0)
      case type
        when "B"
	  raise_validation_error("Cannot set value '#{field}' under class '#{self.class}'. The boolean value can only be 'true' or 'false.")  unless field == 'true' || field == 'false'

        when "S"
          length = extra.to_i
	  raise_validation_error("Cannot set value '#{field}' under class '#{self.class}'. The value is too large.")  unless field.length <= length
	  
	when "I"
          length = extra.to_i
	  int = field.to_s
	  raise_validation_error("Cannot set value '#{field}' under class '#{self.class}'. Integer type should contain only numbers.") unless int =~ /[\d.]+$/
	  raise_validation_error("Cannot set value '#{field}' under class '#{self.class}'. The value is too large.")  unless int.length <= length
	  
        when "D"
	  raise_validation_error("Cannot set value '#{field}' under class '#{self.class}'. The value is too large.")  unless field.length <= 12
	  
        when "M"
	  valid_entries = extra.split(/;/)
	  raise_validation_error("Not a valid multiple choice value '#{field}' under class '#{self.class}'. The values are #{valid_entries.inspect}")  if valid_entries.index(field).nil?

      end
    end
    
    def validate_required(field)
      raise_validation_error("Required value #{field} is missing.")  if field.nil?
    end

    def raise_validation_error(error)
      raised_from = caller.detect do | source | source.split(/\//)[-1].split(/:/)[0] == $0 end
      raised_from = raised_from.split(/:/) rescue nil
      if raised_from.nil?
        raise error
      elsif raised_from[2].nil?
        raise "exception '#{error}' raised from #{raised_from[0]} line #{raised_from[1]}"
      else
        raise "exception '#{error}' raised from #{raised_from[0]} line #{raised_from[1]}, #{raised_from[2]}"
      end
    end
    
    def generate_random_id
      rand_value = rand(8 * 8)
      now = Time.now.to_s
      md5sum = Digest::MD5.new
      md5sum << rand_value.to_s
      md5sum << now
      md5sum << "CKURU"
      md5sum.hexdigest.slice!(0..24)
    end
    
  public
    def initialize(variables = {})
      super(variables)
      self.validate
      self.generate
    end

    def construct_xml(fields, attributes={})
      @xml_file = LitleXmlDoc.new(@template)
      unless fields.nil?
        for field,value in fields do
	  required, type, extra = @xml_file.get_validation_attrs(field)
	  validate_required(value) if required=='true'
	  unless type.nil? || value.nil?
	    validate_value(value, type, extra)
          end
	  if value.nil?
	    @xml_file.del_element(field)
	  else
            @xml_file.set_element_text(field,value)
	  end
	end
      end
      unless attributes.nil?
        for attr,value in attributes do
	  required, type, extra = @xml_file.get_validation_attrs('/',attr)
	  validate_required(value) if required=='true'
	  unless type.nil? || value.nil?
	    validate_value(value, type, extra)
          end
	  value = '' if value.nil?
	  @xml_file.set_attribute_value('/',attr,value)
	end
      end
    end
    
    def xml
      return nil if @xml_file.nil?
      return @xml_file.to_s
    end
    
    def xml_root_element
      @xml_file.root_element
    end
    
    def insert_xml_element(element)
      @xml_file.insert_xml_element(element)
    end
    
    def insert_xml_field(name,value)
      @xml_file.insert_xml_field(name,value)
    end
  end


  class Gateway < CkuruTools::HashInitializerClass
  private
    attr_accessor :password, :merchantId
   
    def construct_xml_header
      xml_header = LitleXmlDoc.new(@template)
      xml_header.set_attribute_value(@id_path,@id_attribute,@merchantId)
      xml_header.set_element_text(@username_path,@username)
      xml_header.set_element_text(@password_path,@password)
      return xml_header
    end

  public
    attr_accessor :username
    def initialize(variables={})
      super(variables)
      @id_path='/'
      @id_attribute='merchantId'
      @username_path='authentication/user'
      @password_path='authentication/password'
      @template='header.rxml'
    end
  
    def submit_transaction(transaction)
      p "-----=====-----"
      p "Litle URL: " + $litle_url
      p transaction.to_s
      uri = URI.parse($litle_url)
      site = Net::HTTP.new(uri.host, uri.port)
      site.use_ssl = true
      site.verify_mode    = OpenSSL::SSL::VERIFY_NONE
      data = transaction.to_s.gsub(/>[\n ]{2,20}</, ">\n<")
#      puts data
      result = site.post($litle_path, data)
      p result.body.to_s
      p "-----=====-----"
      case result
        when Net::HTTPSuccess
	  return result.body
	else
          raise "\n\n\nError occured when posting a request. Error is : #{result.value}\n\n\n"
      end	
    end
   
    def authorize(variables)
      xml_header = construct_xml_header
      xml_transaction = LitleOnline::Transaction::Authorization.new(variables)
      xml_header.insert_xml_element(xml_transaction.xml_root_element)
      xml_response = submit_transaction(xml_header)
      LitleOnline::Transaction::AuthorizationResponse.new(xml_response)
    end

    def auth_reversal(variables)
      xml_header = construct_xml_header
      xml_transaction = LitleOnline::Transaction::AuthorizationReversal.new(variables)
      xml_header.insert_xml_element(xml_transaction.xml_root_element)
      xml_response = submit_transaction(xml_header)
      LitleOnline::Transaction::AuthorizationReversalResponse.new(xml_response)
    end

    def avs_only(variables)
      xml_header = construct_xml_header
      xml_transaction = LitleOnline::Transaction::AVSOnly.new(variables)
      xml_header.insert_xml_element(xml_transaction.xml_root_element)
      xml_response = submit_transaction(xml_header)
      LitleOnline::Transaction::AVSOnlyResponse.new(xml_response)
    end

    def capture(variables)
      xml_header = construct_xml_header
      xml_transaction = LitleOnline::Transaction::Capture.new(variables)
      xml_header.insert_xml_element(xml_transaction.xml_root_element)
      xml_response = submit_transaction(xml_header)
      LitleOnline::Transaction::CaptureResponse.new(xml_response)
    end

    def sale(variables)
      xml_header = construct_xml_header
      xml_transaction = LitleOnline::Transaction::Sale.new(variables)
      xml_header.insert_xml_element(xml_transaction.xml_root_element)
      xml_response = submit_transaction(xml_header)
      LitleOnline::Transaction::SaleResponse.new(xml_response)
    end

    def credit_with_transaction_id(variables)
      xml_header = construct_xml_header
      xml_transaction = LitleOnline::Transaction::CreditWithTransactionId.new(variables)
      xml_header.insert_xml_element(xml_transaction.xml_root_element)
      xml_response = submit_transaction(xml_header)
      LitleOnline::Transaction::CreditResponse.new(xml_response)
    end

    def credit(variables)
      xml_header = construct_xml_header
      xml_transaction = LitleOnline::Transaction::Credit.new(variables)
      xml_header.insert_xml_element(xml_transaction.xml_root_element)
      xml_response = submit_transaction(xml_header)
      LitleOnline::Transaction::CreditResponse.new(xml_response)
    end

    def void(variables)
      xml_header = construct_xml_header
      xml_transaction = LitleOnline::Transaction::Void.new(variables)
      xml_header.insert_xml_element(xml_transaction.xml_root_element)
      xml_response = submit_transaction(xml_header)
      LitleOnline::Transaction::VoidResponse.new(xml_response)
    end


  end
  
end

# Have to rewrite the to_string method of REXML::Attribute class as Litle doesn't support
# single quoted XML attributes.
REXML::Attribute.class_eval( %q^
  def to_string
    %Q[#@expanded_name="#{to_s().gsub(/"/, '&quot;')}"]
  end
^)
