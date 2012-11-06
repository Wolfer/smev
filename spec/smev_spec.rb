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
      hash = {"name"=>"SendRequestRq", "type"=>"element", "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[{"name"=>"Message", "type"=>"element", "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[{"name"=>"Sender", "type"=>"element", "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[{"name"=>"Code", "type"=>"element", "value"=>{"value"=>"", "type"=>"string", "restriction"=>{}}}, {"name"=>"Name", "type"=>"element", "value"=>{"value"=>"", "type"=>"string", "restriction"=>{}}}]}]}, {"name"=>"Recipient", "type"=>"element", "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[{"name"=>"Code", "type"=>"element", "value"=>{"value"=>"", "type"=>"string", "restriction"=>{}}}, {"name"=>"Name", "type"=>"element", "value"=>{"value"=>"", "type"=>"string", "restriction"=>{}}}]}]}, {"name"=>"Originator", "type"=>"element", "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[{"name"=>"Code", "type"=>"element", "value"=>{"value"=>"", "type"=>"string", "restriction"=>{}}}, {"name"=>"Name", "type"=>"element", "value"=>{"value"=>"", "type"=>"string", "restriction"=>{}}}]}]}, {"name"=>"TypeCode", "type"=>"element", "value"=>{"value"=>"", "type"=>"string", "restriction"=>{}}}, {"name"=>"Date", "type"=>"element", "value"=>{"value"=>"", "type"=>"dateTime", "restriction"=>{}}}, {"name"=>"RequestIdRef", "type"=>"element", "min_occurs"=>0, "value"=>{"value"=>"", "type"=>"string", "restriction"=>{}}}, {"name"=>"OriginRequestIdRef", "type"=>"element", "min_occurs"=>0, "value"=>{"value"=>"", "type"=>"string", "restriction"=>{}}}, {"name"=>"ServiceCode", "type"=>"element", "min_occurs"=>0, "value"=>{"value"=>"", "type"=>"string", "restriction"=>{}}}, {"name"=>"CaseNumber", "type"=>"element", "min_occurs"=>0, "value"=>{"value"=>"", "type"=>"string", "restriction"=>{}}}]}]}, {"name"=>"MessageData", "type"=>"element", "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[{"name"=>"AppData", "type"=>"element", "min_occurs"=>0, "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[{"name"=>"Документ", "type"=>"element", "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[{"name"=>"СвЮЛ", "type"=>"element", "attributes"=>[{"value"=>"9", "type"=>"string", "restriction"=>{"minlength"=>1, "maxlength"=>1000}, "name"=>"НаимЮЛ", "use"=>"required"}, {"value"=>"9999999999", "type"=>"string", "restriction"=>{"length"=>10, "pattern"=>/([0-9]{1}[1-9]{1}|[1-9]{1}[0-9]{1})[0-9]{8}/n}, "name"=>"ИННЮЛ", "use"=>"required"}, {"value"=>"9999999999999", "type"=>"string", "restriction"=>{"length"=>13, "pattern"=>/[0-9]{13}/n}, "name"=>"ОГРН", "use"=>"required"}]}, {"name"=>"ЗапросНП", "type"=>"element", "children"=>[{"name"=>"Smev::XSD::Choice", "type"=>"choice", "children"=>[{"name"=>"ИННЮЛ", "type"=>"element", "value"=>{"value"=>"9999999999", "type"=>"string", "restriction"=>{"length"=>10, "pattern"=>/([0-9]{1}[1-9]{1}|[1-9]{1}[0-9]{1})[0-9]{8}/n}}}, {"name"=>"ИННФЛ", "type"=>"element", "value"=>{"value"=>"999999999999", "type"=>"string", "restriction"=>{"length"=>12, "pattern"=>/([0-9]{1}[1-9]{1}|[1-9]{1}[0-9]{1})[0-9]{10}/n}}}]}], "attributes"=>[{"value"=>"9999999999", "type"=>"string", "restriction"=>{"length"=>10, "pattern"=>/(((0[1-9]{1}|[1-2]{1}[0-9]{1})\.(0[1-9]{1}|1[0-2]{1}))|((30)\.(0[1,3-9]{1}|1[0-2]{1}))|((31)\.(0[1,3,5,7,8]{1}|1[0,2]{1})))\.(19[0-9]{2}|20[0-9]{2})/n}, "name"=>"ДатаНа", "use"=>"required"}]}]}], "attributes"=>[{"value"=>"4.02", "type"=>"string", "restriction"=>{"enumeration"=>["4.02"], "minlength"=>1, "maxlength"=>5}, "name"=>"ВерсФорм", "use"=>"required"}, {"value"=>"999999999999999999999999999999999999", "type"=>"string", "restriction"=>{"length"=>36}, "name"=>"ИдЗапросП", "use"=>"optional"}]}]}]}, {"name"=>"AppDocument", "type"=>"element", "min_occurs"=>0, "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[{"name"=>"BinaryData", "type"=>"element", "value"=>{"value"=>"", "type"=>"base64Binary", "restriction"=>{}}}, {"name"=>"Reference", "type"=>"element", "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[{"name"=>"Include", "type"=>"element", "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence"}], "attributes"=>[{"value"=>"", "type"=>"anyURI", "restriction"=>{}, "name"=>"href", "use"=>"required"}]}]}]}, {"name"=>"DigestValue", "type"=>"element", "value"=>{"value"=>"", "type"=>"base64Binary", "restriction"=>{}}}]}]}]}]}]}]}
      #{"name"=>"Документ", "type"=>"element", "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[{"name"=>"СвЮЛ", "type"=>"element", "attributes"=>[{"value"=>"9", "type"=>"string", "restriction"=>{"minlength"=>1, "maxlength"=>1000}, "name"=>"НаимЮЛ", "use"=>"required"}, {"value"=>"9999999999", "type"=>"string", "restriction"=>{"length"=>10, "pattern"=>/([0-9]{1}[1-9]{1}|[1-9]{1}[0-9]{1})[0-9]{8}/n}, "name"=>"ИННЮЛ", "use"=>"required"}, {"value"=>"9999999999999", "type"=>"string", "restriction"=>{"length"=>13, "pattern"=>/[0-9]{13}/n}, "name"=>"ОГРН", "use"=>"required"}]}, {"name"=>"ЗапросНП", "type"=>"element", "children"=>[{"name"=>"Smev::XSD::Choice", "type"=>"choice", "children"=>[{"name"=>"ИННЮЛ", "type"=>"element", "value"=>{"value"=>"9999999999", "type"=>"string", "restriction"=>{"length"=>10, "pattern"=>/([0-9]{1}[1-9]{1}|[1-9]{1}[0-9]{1})[0-9]{8}/n}}}, {"name"=>"ИННФЛ", "type"=>"element", "value"=>{"value"=>"999999999999", "type"=>"string", "restriction"=>{"length"=>12, "pattern"=>/([0-9]{1}[1-9]{1}|[1-9]{1}[0-9]{1})[0-9]{10}/n}}}]}], "attributes"=>[{"value"=>"9999999999", "type"=>"string", "restriction"=>{"length"=>10, "pattern"=>/(((0[1-9]{1}|[1-2]{1}[0-9]{1})\.(0[1-9]{1}|1[0-2]{1}))|((30)\.(0[1,3-9]{1}|1[0-2]{1}))|((31)\.(0[1,3,5,7,8]{1}|1[0,2]{1})))\.(19[0-9]{2}|20[0-9]{2})/n}, "name"=>"ДатаНа", "use"=>"required"}]}]}], "attributes"=>[{"value"=>"4.02", "type"=>"string", "restriction"=>{"enumeration"=>["4.02"], "minlength"=>1, "maxlength"=>5}, "name"=>"ВерсФорм", "use"=>"required"}, {"value"=>"999999999999999999999999999999999999", "type"=>"string", "restriction"=>{"length"=>36}, "name"=>"ИдЗапросП", "use"=>"optional"}]}
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
      sm.get_child("ЗапросНП").attribute("ДатаНа").set "1234567890"
      sm.valid?.should be_false
      sm.errors["SendRequestRq"]["MessageData"]["AppData"]["Документ"].should_not include("ЗапросНП")

      # check full fill
      sm.fill_test

      sm.valid?.should be_true
      sm.errors.should eql({})

      # puts sm.as_hash

    end

    it "generate fault" do
      hash =  {"name"=>"Fault", "type"=>"element", "namespace" => "http://schemas.xmlsoap.org/soap/envelope/", "children"=>[
                {"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[
                  {"name"=>"faultcode", "type"=>"element", "value"=>{"value"=>"Client", "type"=>"QName", "restriction"=>{}}},
                  {"name"=>"faultstring", "type"=>"element", "value"=>{"value"=> "fault", "type"=>"string", "restriction"=>{}}}
                ]}
              ]}

      sm = Smev::Message.new hash
      sm.to_xml(false).should_not be_blank
    end

    it 'disable AppDocument' do
      sm.get_child("AppDocument").should_not be_nil
      sm.remove_appdoc
      sm.get_child("AppDocument").should be_nil
    end

    it "dup" do
      ap = sm.get_child("AppData")
      d = ap.dup
      d.as_hash.should eql(ap.as_hash)
      ap.children.max_occurs = 3
      d.children.max_occurs.should_not eql(3)
      
      ap.get_child("СвЮЛ").attribute("ОГРН").set "1111111111111"
      d.get_child("СвЮЛ").attribute("ОГРН").get.should_not eql("1111111111111")

      ap.get_child("ИННЮЛ").set "1111111111111"
      d.get_child("ИННЮЛ").should_not eql("1111111111111")
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
        xml = Builder::XmlMarkup.new
        xml.instruct!
        xml.tag! "xs:schema", { "xmlns:xs" => "http://www.w3.org/2001/XMLSchema", "xmlns:tns" => "qweqwe", "targetNamespace" => "qweqwe", "elementFormDefault" => "qualified" } do
          xml << sm.as_xsd
        end

        tmp_file = Tempfile.new "xsd"
        tmp_file.write xml.target!
        tmp_file.close
        new_sm = Smev::Message.new WSDL::Importer.import( "file://" + tmp_file.path ).elements.first
        new_sm.fill_test
        sm.fill_test
        xml_sm = sm.get_child("AppData").children.first.to_xml([])
        xml_new_sm = new_sm.struct.first.to_xml([])
        xml_sm.should eql(xml_new_sm)
      end

    end

    describe 'import from' do

      it 'xml' do
          sm.fill_test
          xml = sm.to_xml(false)
          original_sm = sm.dup
          sm.load_from_xml(xml).should be_true
      end

      it 'hash' do
          sm.fill_test
          hash = sm.to_hash
          original_sm = sm.dup
          sm.load_from_hash(hash).should be_true
      end

      describe '(unbounded)' do
        let(:sm_unb) do
          wsdl = WSDL::Importer.import( "file://" + File.dirname(__FILE__) + "/test_xsd_unbounded/wsdl" )
          Smev::Message.new wsdl.find_by_action(wsdl.methods.first)
        end

        it "xml" do
          xml = File.read File.dirname(__FILE__) + "/example.xml"
          sm_unb.load_from_xml xml
          inns = sm.search_child("ИННЮЛ")
          inns.size.should eql(3)
          inns.shift.get.should eql("9999999999")
          inns.shift.get.should eql("8888888888")
          inns.shift.get.should eql("7777777777")
        end

        it "hash" do
          
        end

      end

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
