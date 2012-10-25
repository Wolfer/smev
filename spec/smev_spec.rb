require 'smev'
require 'spec_helper'

describe Smev::Message do		

	before(:all) do 
		@wsdl = WSDL::Importer.import( "file://" + File.dirname(__FILE__) + "/test_xsd/wsdl" )
		@xsd = @wsdl.find_by_action @wsdl.methods.first
	end

	it 'should be create from xsd' do
		sm = Smev::Message.new @xsd
		sm.should be_a(Smev::Message)
	end

	# it 'should be searchable' do
	# 	sm = SmevMessage.new( Service.last(4).first.wsdl.collect_elements.find_name("doleResponse") )
	# 	assert sm.search_child("status").each{ |s| s.value.set "Безработный"}.present?, "Search FAIL"
	# end

	# it 'can be disable appdocument' do
	# 	sm = SmevMessage.new( Service.first.wsdl.find_by_action("queryOPUL"))
	# 	assert_raise(ArgumentError){ sm.to_xml }
	# 	assert sm.load_from_xml File.read("#{Rails.root}/spec/query_opul.xml")
	# 	sm.to_xml.index("AppDocument").should_not be_nil
	# 	sm.remove_appdoc
	# 	sm.to_xml.index("AppDocument").should be_nil
	# end

	# it 'should be load from xml and to_xml' do
	# 	sm = SmevMessage.new( Service.first.wsdl.find_by_action("queryOPUL"))
	# 	assert_raise(ArgumentError){ sm.to_xml }

	# 	assert sm.load_from_xml( File.read("#{Rails.root}/spec/query_opul.xml") )

	# 	assert (child = sm.search_child("СвЮЛ").first )
	# 	child.attributes.find{ |a| a.name == "ОГРН" }.get.should eql("2222222222222")
	# 	result = sm.to_xml
	# 	File.open("/tmp/1.xml", "w"){|f| f.write result }
	# 	examples = ['<m2:Документ ВерсФорм="4.02" ТипИнф="ЗапрПостУч" ИдЗапрос="111111111111111111111111111111111111">', 	'<m2:СвЮЛ НаимЮЛ="2" ИННЮЛ="2222222222" ОГРН="2222222222222"/>',  '<m2:ЗапросЮЛ ОГРН="2222222222222" ИННЮЛ="2222222222" КППОП="222222222"/>']
	# 	examples.each do |ex|
	# 		result.index(ex).should_not be_nil
	# 	end
	# end


	# it 'should be convert to xml' do
	# 	sm = SmevMessage.new( Service.last(3).first.wsdl.collect_elements.find_name("doleResponse") )
	# 	assert_raise(ArgumentError){ sm.to_xml }
	# 	sm.search_child("TypeCode").first.value.set "GSRV"
	# 	sm.search_child("Status").first.value.set "REQUEST"
	# 	sm.search_child("status").each{ |s| s.value.set "Безработный"}
	# 	sm.to_xml.should be_a_kind_of(String)
	# end

	# it 'should load from hash' do
	# 	sm = SmevMessage.new( Service.last(3).first.wsdl.collect_elements.find_name("doleResponse").search_child("months").children )
	# 	h1 = {"Anything" => {"Anythingelse" => "test"}}
	# 	assert sm.load_from_hash(h1)

	# 	h1 = { "month" => { "monthName" => "555555555555", "dole" => [ 
	# 		{ "type" => "6", "balance" => { "withheld" => "1", "returned" => "2", "paid" => "3" }  }, 
	# 		{ "type" => "6", "balance" => { "withheld" => "z", "returned" => "w", "paid" => "q" }  }, 
	# 		{ "type" => "9", "balance" => { "withheld" => "9", "returned" => "9", "paid" => "9" } } ] } }
	# 	sm.load_from_hash h1
	# 	sm.search_child("dole").size.should eql(3)
	# 	sm.search_child("monthName").first.value.get.should eql("555555555555")
	# 	sm.search_child("paid").map{|c| c.value.get}.should eql(%w(3 q 9) )
	# 	h1["month"]["dole"].delete h1["month"]["dole"].last
	# 	sm.load_from_hash h1
	# 	sm.search_child("dole").size.should eql(2)

	# 	sm = SmevMessage.new( Service.first.wsdl.find_by_action("queryOPUL").search_child("Include") )
	# 	h2 = {"Include" => {"Anything" => "Anywhere"} }
	# 	sm.load_from_hash h2

		
	# end
	
	# it 'testing spec' do
	#   sm = SmevMessage.new( QueryType.last.wsdl.find_by_action("SendShortULRequest") )
	#   sm.search_child("TypeCode").first.value.set "GSRV"
	#   sm.search_child("Status").first.value.set "REQUEST"
	#   sm.search_child("Status").first.value.set "REQUEST"
	#   sm.search_child("Документ").first.attributes.first.set "4.02"
	#   sm.search_child("Документ").first.attributes.last.set "123456789012345678901234567890123456"
	#   z = sm.search_child("ЗапросЮЛ").first
	#   z.attributes.first.set "123456789012345678901234567890123456"
	#   puts ">DON't SEE ME>1" + z.valid?.inspect
	#   puts ">>2" + z.children.first.valid?.inspect
	#   sm.to_xml
	#   assert sm.valid?, 'invalid'
	# end

end
