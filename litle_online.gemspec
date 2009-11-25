--- !ruby/object:Gem::Specification 
name: litle_online
version: !ruby/object:Gem::Version 
  version: 1.0.3
platform: ruby
authors: 
- Andrius, Bret
autorequire: 
bindir: bin
cert_chain: []

date: 2009-11-01 23:00:00 -07:00
default_executable: 
dependencies: 
- !ruby/object:Gem::Dependency 
  name: bones
  type: :development
  version_requirement: 
  version_requirements: !ruby/object:Gem::Requirement 
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: 2.5.1
    version: 
description: Litle gateway implementation for ActiveMerchant.
email: bret@ckuru.com
executables: 
- litle_online
extensions: []

extra_rdoc_files: 
- History.txt
- README.txt
- bin/litle_online
- lib/litle_online/templates/auth_reversal.rxml
- lib/litle_online/templates/authorization.rxml
- lib/litle_online/templates/avs_only.rxml
- lib/litle_online/templates/bill_to_address.rxml
- lib/litle_online/templates/billmelater.rxml
- lib/litle_online/templates/capture.rxml
- lib/litle_online/templates/cardholder_auth.rxml
- lib/litle_online/templates/credit_card.rxml
- lib/litle_online/templates/credit_external.rxml
- lib/litle_online/templates/credit_internal.rxml
- lib/litle_online/templates/custom_billing.rxml
- lib/litle_online/templates/customer_info.rxml
- lib/litle_online/templates/detail_tax.rxml
- lib/litle_online/templates/enhanced_data.rxml
- lib/litle_online/templates/header.rxml
- lib/litle_online/templates/line_item.rxml
- lib/litle_online/templates/paypal.rxml
- lib/litle_online/templates/pos.rxml
- lib/litle_online/templates/processing_instructions.rxml
- lib/litle_online/templates/sale.rxml
- lib/litle_online/templates/ship_to_address.rxml
- lib/litle_online/templates/void.rxml
files: 
- History.txt
- README.txt
- Rakefile
- bin/litle_online
- lib/litle_online.rb
- lib/litle_online/conf/conf.rb
- lib/litle_online/engine/litle_active_merchant.rb
- lib/litle_online/engine/litle_address.rb
- lib/litle_online/engine/litle_billmelater.rb
- lib/litle_online/engine/litle_cardholder_auth.rb
- lib/litle_online/engine/litle_core.rb
- lib/litle_online/engine/litle_credit_card.rb
- lib/litle_online/engine/litle_custom_billing.rb
- lib/litle_online/engine/litle_customer_info.rb
- lib/litle_online/engine/litle_enhanced_data.rb
- lib/litle_online/engine/litle_error.rb
- lib/litle_online/engine/litle_paypal.rb
- lib/litle_online/engine/litle_pos.rb
- lib/litle_online/engine/litle_processing_instructions.rb
- lib/litle_online/engine/litle_requests.rb
- lib/litle_online/engine/litle_response.rb
- lib/litle_online/engine/litle_xml_doc.rb
- lib/litle_online/templates/auth_reversal.rxml
- lib/litle_online/templates/authorization.rxml
- lib/litle_online/templates/avs_only.rxml
- lib/litle_online/templates/bill_to_address.rxml
- lib/litle_online/templates/billmelater.rxml
- lib/litle_online/templates/capture.rxml
- lib/litle_online/templates/cardholder_auth.rxml
- lib/litle_online/templates/credit_card.rxml
- lib/litle_online/templates/credit_external.rxml
- lib/litle_online/templates/credit_internal.rxml
- lib/litle_online/templates/custom_billing.rxml
- lib/litle_online/templates/customer_info.rxml
- lib/litle_online/templates/detail_tax.rxml
- lib/litle_online/templates/enhanced_data.rxml
- lib/litle_online/templates/header.rxml
- lib/litle_online/templates/line_item.rxml
- lib/litle_online/templates/paypal.rxml
- lib/litle_online/templates/pos.rxml
- lib/litle_online/templates/processing_instructions.rxml
- lib/litle_online/templates/sale.rxml
- lib/litle_online/templates/ship_to_address.rxml
- lib/litle_online/templates/void.rxml
- spec/litle_online_spec.rb
- spec/spec_helper.rb
- test/test_litle_online.rb
has_rdoc: true
homepage: http://www.ckuru.com
licenses: []

post_install_message: 
rdoc_options: 
- --main
- README.txt
require_paths: 
- lib
required_ruby_version: !ruby/object:Gem::Requirement 
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      version: "0"
  version: 
required_rubygems_version: !ruby/object:Gem::Requirement 
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      version: "0"
  version: 
requirements: []

rubyforge_project: litle_online
rubygems_version: 1.3.4
signing_key: 
specification_version: 3
summary: Litle gateway implementation for ActiveMerchant
test_files: 
- test/test_litle_online.rb
