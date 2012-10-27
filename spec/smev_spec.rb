require 'smev'
require 'spec_helper'

describe Smev::Message do   

  let(:xsd) do
    wsdl = WSDL::Importer.import( "file://" + File.dirname(__FILE__) + "/test_xsd/wsdl" )
    wsdl.find_by_action wsdl.methods.first
  end

  describe "created" do

    it 'from xsd' do
      sm = Smev::Message.new xsd
      sm.struct.should_not be_empty
      #FIXME add as_xsd checking
    end

    it 'from hash' do
      hash = {"name"=>"SendRequestRq", "type"=>"element", "min_occurs"=>1, "max_occurs"=>1, "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "min_occurs"=>1, "max_occurs"=>1, "children"=>[{"name"=>"Message", "type"=>"element", "min_occurs"=>1, "max_occurs"=>1, "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "min_occurs"=>1, "max_occurs"=>1, "children"=>[{"name"=>"Sender", "type"=>"element", "min_occurs"=>1, "max_occurs"=>1, "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "min_occurs"=>1, "max_occurs"=>1, "children"=>[{"name"=>"Code", "type"=>"element", "min_occurs"=>1, "max_occurs"=>1}, {"name"=>"Name", "type"=>"element", "min_occurs"=>1, "max_occurs"=>1}]}]}, {"name"=>"Recipient", "type"=>"element", "min_occurs"=>1, "max_occurs"=>1, "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "min_occurs"=>1, "max_occurs"=>1, "children"=>[{"name"=>"Code", "type"=>"element", "min_occurs"=>1, "max_occurs"=>1}, {"name"=>"Name", "type"=>"element", "min_occurs"=>1, "max_occurs"=>1}]}]}, {"name"=>"Originator", "type"=>"element", "min_occurs"=>1, "max_occurs"=>1, "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "min_occurs"=>1, "max_occurs"=>1, "children"=>[{"name"=>"Code", "type"=>"element", "min_occurs"=>1, "max_occurs"=>1}, {"name"=>"Name", "type"=>"element", "min_occurs"=>1, "max_occurs"=>1}]}]}, {"name"=>"TypeCode", "type"=>"element", "min_occurs"=>1, "max_occurs"=>1}, {"name"=>"Date", "type"=>"element", "min_occurs"=>1, "max_occurs"=>1}, {"name"=>"RequestIdRef", "type"=>"element", "min_occurs"=>0, "max_occurs"=>1}, {"name"=>"OriginRequestIdRef", "type"=>"element", "min_occurs"=>0, "max_occurs"=>1}, {"name"=>"ServiceCode", "type"=>"element", "min_occurs"=>0, "max_occurs"=>1}, {"name"=>"CaseNumber", "type"=>"element", "min_occurs"=>0, "max_occurs"=>1}]}]}, {"name"=>"MessageData", "type"=>"element", "min_occurs"=>1, "max_occurs"=>1, "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "min_occurs"=>1, "max_occurs"=>1, "children"=>[{"name"=>"AppData", "type"=>"element", "min_occurs"=>0, "max_occurs"=>1, "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "min_occurs"=>1, "max_occurs"=>1, "children"=>[{"name"=>"Документ", "type"=>"element", "min_occurs"=>1, "max_occurs"=>1, "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "min_occurs"=>1, "max_occurs"=>1, "children"=>[{"name"=>"СвЮЛ", "type"=>"element", "min_occurs"=>1, "max_occurs"=>1, "attributes"=>[{"value"=>"9", "restriction"=>{"minlength"=>1, "maxlength"=>1000}, "name"=>"НаимЮЛ", "use"=>"required"}, {"value"=>"", "restriction"=>{}, "name"=>"ИННЮЛ", "use"=>"required"}, {"value"=>"", "restriction"=>{}, "name"=>"ОГРН", "use"=>"required"}]}, {"name"=>"ЗапросНП", "type"=>"element", "min_occurs"=>1, "max_occurs"=>1, "children"=>[{"name"=>"Smev::XSD::Choice", "type"=>"choice", "min_occurs"=>1, "max_occurs"=>1, "children"=>[{"name"=>"ИННЮЛ", "type"=>"element", "min_occurs"=>1, "max_occurs"=>1}, {"name"=>"ИННФЛ", "type"=>"element", "min_occurs"=>1, "max_occurs"=>1}]}], "attributes"=>[{"value"=>"", "restriction"=>{}, "name"=>"ДатаНа", "use"=>"required"}]}]}], "attributes"=>[{"value"=>"4.02", "restriction"=>{"enumeration"=>["4.02"], "minlength"=>1, "maxlength"=>5}, "name"=>"ВерсФорм", "use"=>"required"}, {"value"=>"999999999999999999999999999999999999", "restriction"=>{"length"=>36}, "name"=>"ИдЗапросП", "use"=>"optional"}]}]}]}, {"name"=>"AppDocument", "type"=>"element", "min_occurs"=>0, "max_occurs"=>1, "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "min_occurs"=>1, "max_occurs"=>1, "children"=>[{"name"=>"BinaryData", "type"=>"element", "min_occurs"=>1, "max_occurs"=>1}, {"name"=>"Reference", "type"=>"element", "min_occurs"=>1, "max_occurs"=>1, "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "min_occurs"=>1, "max_occurs"=>1, "children"=>[{"name"=>"Include", "type"=>"element", "min_occurs"=>1, "max_occurs"=>1, "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "min_occurs"=>1, "max_occurs"=>1}], "attributes"=>[{"value"=>"", "restriction"=>{}, "name"=>"href", "use"=>"required"}]}]}]}, {"name"=>"DigestValue", "type"=>"element", "min_occurs"=>1, "max_occurs"=>1}]}]}]}]}]}]}
      sm = Smev::Message.new hash
      sm.struct.should_not be_empty
      sm.as_hash.should eq([hash])
    end

  end

  describe "should be" do

    let!(:sm){ Smev::Message.new xsd }

    it 'searchable' do
      result = sm.search_child("AppData")
      result.should_not be_empty
      result.first.should be_a(Smev::XSD::Element)
    end

    it 'validate' do
      sm.valid?.should be_false

      # check "choice" exclude concurent
      sm.get_child("ИННЮЛ").set "1234567890"
      sm.valid?.should be_false
      sm.errors["SendRequestRq"]["MessageData"]["AppData"]["Документ"].should_not include("ЗапросНП")

      # check full fill
      sm.fill_test

      sm.valid?.should be_true
      sm.errors.should be_empty

    end

    it 'disable AppDocument' do
      sm.get_child("AppDocument").should_not be_nil
      sm.remove_appdoc
      sm.get_child("AppDocument").should be_nil
    end

    describe "export to" do

      it 'hash' do
        hash = sm.as_hash
        hash.should be_a(Array)
        hash.should_not be_empty
        hash.first.should include("type")
      end

      it 'xml' do
        sm.fill_test
        xml = sm.to_xml(false)
        xml.should be_a(String)
        xml.should_not be_empty
      end

      it 'xsd' do
      end

    end

    it 'import from xml' do
        sm.fill_test
        xml = sm.to_xml(false)
        original_sm = sm.dup
        sm.load_from_xml xml
        (sm === original_sm).should be_true
    end

  end




  # it 'should be load from xml and to_xml' do
  #   sm = SmevMessage.new( Service.first.wsdl.find_by_action("queryOPUL"))
  #   assert_raise(ArgumentError){ sm.to_xml }

  #   assert sm.load_from_xml( File.read("#{Rails.root}/spec/query_opul.xml") )

  #   assert (child = sm.search_child("СвЮЛ").first )
  #   child.attributes.find{ |a| a.name == "ОГРН" }.get.should eql("2222222222222")
  #   result = sm.to_xml
  #   File.open("/tmp/1.xml", "w"){|f| f.write result }
  #   examples = ['<m2:Документ ВерсФорм="4.02" ТипИнф="ЗапрПостУч" ИдЗапрос="111111111111111111111111111111111111">',  '<m2:СвЮЛ НаимЮЛ="2" ИННЮЛ="2222222222" ОГРН="2222222222222"/>',  '<m2:ЗапросЮЛ ОГРН="2222222222222" ИННЮЛ="2222222222" КППОП="222222222"/>']
  #   examples.each do |ex|
  #     result.index(ex).should_not be_nil
  #   end
  # end


  # it 'should be convert to xml' do
  #   sm = SmevMessage.new( Service.last(3).first.wsdl.collect_elements.find_name("doleResponse") )
  #   assert_raise(ArgumentError){ sm.to_xml }
  #   sm.search_child("TypeCode").first.value.set "GSRV"
  #   sm.search_child("Status").first.value.set "REQUEST"
  #   sm.search_child("status").each{ |s| s.value.set "Безработный"}
  #   sm.to_xml.should be_a_kind_of(String)
  # end

  # it 'should load from hash' do
  #   sm = SmevMessage.new( Service.last(3).first.wsdl.collect_elements.find_name("doleResponse").search_child("months").children )
  #   h1 = {"Anything" => {"Anythingelse" => "test"}}
  #   assert sm.load_from_hash(h1)

  #   h1 = { "month" => { "monthName" => "555555555555", "dole" => [ 
  #     { "type" => "6", "balance" => { "withheld" => "1", "returned" => "2", "paid" => "3" }  }, 
  #     { "type" => "6", "balance" => { "withheld" => "z", "returned" => "w", "paid" => "q" }  }, 
  #     { "type" => "9", "balance" => { "withheld" => "9", "returned" => "9", "paid" => "9" } } ] } }
  #   sm.load_from_hash h1
  #   sm.search_child("dole").size.should eql(3)
  #   sm.search_child("monthName").first.value.get.should eql("555555555555")
  #   sm.search_child("paid").map{|c| c.value.get}.should eql(%w(3 q 9) )
  #   h1["month"]["dole"].delete h1["month"]["dole"].last
  #   sm.load_from_hash h1
  #   sm.search_child("dole").size.should eql(2)

  #   sm = SmevMessage.new( Service.first.wsdl.find_by_action("queryOPUL").search_child("Include") )
  #   h2 = {"Include" => {"Anything" => "Anywhere"} }
  #   sm.load_from_hash h2

    
  # end
  
end
