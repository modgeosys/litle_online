require 'rexml/document'
include REXML

module LitleOnline
  class LitleXmlDoc

  private
    def find_element_by_name(element_root, name)
       element_root.each_element() do |element| 
         tag = element.expanded_name
         return element if (tag == name)
       end
       return nil
    end
    
  
    def xml_set_element_text(element_root, path, text)
       element=element_root
       path.split('/').each do |context|
         next if context == ''
         element = find_element_by_name(element,context)
         return nil if element.nil?
       end
       element.text = text
       return element
    end
    
    def xml_set_attribute_text(element_root, path, attribute, text)
       element=element_root
       path.split('/').each do |context|
         next if context == ''
         element = find_element_by_name(element,context)
         return nil if element.nil?
       end
       element.attributes[attribute] = text
    end
  

    def xml_del_element(element_root, path)
       element=element_root
       parent=element_root
       path.split('/').each do |context|
         next if context == ''
	 parent = element
         element = find_element_by_name(element,context)
         return nil if element.nil?
       end
       parent.delete_element(element)
       return element
    end


  public
    def initialize(template)
      @template_file = template
      full_template_path = ::File.join($template_path, template)
      return nil if !File.exist?(full_template_path)
      template_file = File.new(full_template_path)
      @xml_doc = Document.new(template_file)
      xml_decl = XMLDecl.new(nil,'UTF-8')
      xml_decl.nowrite
      @xml_doc << xml_decl
      @xml_root_level = @xml_doc.root
    end

    def get_validation_attrs(path,attribute=nil)
       element=@xml_root_level
       path.split('/').each do |context|
         next if context == ''
         element = find_element_by_name(element,context)
         return nil if element.nil?
       end
       text = element.text
       text = element.attributes[attribute] unless attribute.nil?
       if text=~ /^(true|false):(B|S|I|D|M)/
         required,type,length = text.split(/:/)
       end
    end

    def set_element_text(path,text)
       xml_set_element_text(@xml_root_level,path,text)
    end
  
    def set_attribute_value(path,attribute,text)
       xml_set_attribute_text(@xml_root_level,path,attribute,text)
    end

    def del_element(path)
       xml_del_element(@xml_root_level,path)
    end
  
    def to_s
      @xml_doc.to_s
#      return @xml_root_level.to_s
    end
    
    def root_element
      return @xml_root_level
    end
    
    def insert_xml_element(element)
      @xml_root_level.add_element(element)
    end

    def insert_xml_field(name, value)
      element = @xml_root_level.add_element(name)
      element.text = value
    end
    
  end
end
