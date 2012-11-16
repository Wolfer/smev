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
      hash = {"name"=>"SendRequestRq", "type"=>"element", "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[{"name"=>"Message", "type"=>"element", "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[{"name"=>"Sender", "type"=>"element", "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[{"name"=>"Code", "type"=>"element", "value"=>{"type"=>"string", "restriction"=>{}}}, {"name"=>"Name", "type"=>"element", "value"=>{"type"=>"string", "restriction"=>{}}}]}]}, {"name"=>"Recipient", "type"=>"element", "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[{"name"=>"Code", "type"=>"element", "value"=>{"type"=>"string", "restriction"=>{}}}, {"name"=>"Name", "type"=>"element", "value"=>{"type"=>"string", "restriction"=>{}}}]}]}, {"name"=>"Originator", "type"=>"element", "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[{"name"=>"Code", "type"=>"element", "value"=>{"type"=>"string", "restriction"=>{}}}, {"name"=>"Name", "type"=>"element", "value"=>{"type"=>"string", "restriction"=>{}}}]}]}, {"name"=>"TypeCode", "type"=>"element", "value"=>{"type"=>"string", "restriction"=>{}}}, {"name"=>"Date", "type"=>"element", "value"=>{"type"=>"dateTime", "restriction"=>{}}}, {"name"=>"RequestIdRef", "type"=>"element", "min_occurs"=>0, "value"=>{"type"=>"string", "restriction"=>{}}}, {"name"=>"OriginRequestIdRef", "type"=>"element", "min_occurs"=>0, "value"=>{"type"=>"string", "restriction"=>{}}}, {"name"=>"ServiceCode", "type"=>"element", "min_occurs"=>0, "value"=>{"type"=>"string", "restriction"=>{}}}, {"name"=>"CaseNumber", "type"=>"element", "min_occurs"=>0, "value"=>{"type"=>"string", "restriction"=>{}}}]}]}, {"name"=>"MessageData", "type"=>"element", "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[{"name"=>"AppData", "type"=>"element", "min_occurs"=>0, "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[{"name"=>"Документ", "type"=>"element", "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[{"name"=>"СвЮЛ", "type"=>"element", "attributes"=>[{"type"=>"string", "restriction"=>{"minlength"=>1, "maxlength"=>1000}, "name"=>"НаимЮЛ", "use"=>"required"}, {"type"=>"string", "restriction"=>{"length"=>10, "pattern"=>"([0-9]{1}[1-9]{1}|[1-9]{1}[0-9]{1})[0-9]{8}"}, "name"=>"ИННЮЛ", "use"=>"required"}, {"type"=>"string", "restriction"=>{"length"=>13, "pattern"=>"[0-9]{13}"}, "name"=>"ОГРН", "use"=>"required"}]}, {"name"=>"ЗапросНП", "type"=>"element", "children"=>[{"name"=>"Smev::XSD::Choice", "type"=>"choice", "children"=>[{"name"=>"ИННЮЛ", "type"=>"element", "value"=>{"type"=>"string", "restriction"=>{"length"=>10, "pattern"=>"([0-9]{1}[1-9]{1}|[1-9]{1}[0-9]{1})[0-9]{8}"}}}, {"name"=>"ИННФЛ", "type"=>"element", "value"=>{"type"=>"string", "restriction"=>{"length"=>12, "pattern"=>"([0-9]{1}[1-9]{1}|[1-9]{1}[0-9]{1})[0-9]{10}"}}}]}], "attributes"=>[{"type"=>"string", "restriction"=>{"length"=>10, "pattern"=>"(((0[1-9]{1}|[1-2]{1}[0-9]{1})\.(0[1-9]{1}|1[0-2]{1}))|((30)\.(0[1,3-9]{1}|1[0-2]{1}))|((31)\.(0[1,3,5,7,8]{1}|1[0,2]{1})))\.(19[0-9]{2}|20[0-9]{2})"}, "name"=>"ДатаНа", "use"=>"required"}]}]}], "attributes"=>[{"type"=>"string", "restriction"=>{"enumeration"=>["4.02"], "minlength"=>1, "maxlength"=>5}, "name"=>"ВерсФорм", "use"=>"required"}, {"type"=>"string", "restriction"=>{"length"=>36}, "name"=>"ИдЗапросП", "use"=>"optional"}]}]}]}, {"name"=>"AppDocument", "type"=>"element", "min_occurs"=>0, "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[{"name"=>"BinaryData", "type"=>"element", "value"=>{"type"=>"base64Binary", "restriction"=>{}}}, {"name"=>"Reference", "type"=>"element", "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[{"name"=>"Include", "type"=>"element", "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence"}], "attributes"=>[{"type"=>"anyURI", "restriction"=>{}, "name"=>"href", "use"=>"required"}]}]}]}, {"name"=>"DigestValue", "type"=>"element", "value"=>{"type"=>"base64Binary", "restriction"=>{}}}]}]}]}]}]}]}
      #{"name"=>"Документ", "type"=>"element", "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[{"name"=>"СвЮЛ", "type"=>"element", "attributes"=>[{"type"=>"string", "restriction"=>{"minlength"=>1, "maxlength"=>1000}, "name"=>"НаимЮЛ", "use"=>"required"}, {"type"=>"string", "restriction"=>{"length"=>10, "pattern"=>"([0-9]{1}[1-9]{1}|[1-9]{1}[0-9]{1})[0-9]{8}"}, "name"=>"ИННЮЛ", "use"=>"required"}, {"type"=>"string", "restriction"=>{"length"=>13, "pattern"=>"[0-9]{13}"}, "name"=>"ОГРН", "use"=>"required"}]}, {"name"=>"ЗапросНП", "type"=>"element", "children"=>[{"name"=>"Smev::XSD::Choice", "type"=>"choice", "children"=>[{"name"=>"ИННЮЛ", "type"=>"element", "value"=>{"type"=>"string", "restriction"=>{"length"=>10, "pattern"=>"([0-9]{1}[1-9]{1}|[1-9]{1}[0-9]{1})[0-9]{8}"}}}, {"name"=>"ИННФЛ", "type"=>"element", "value"=>{"type"=>"string", "restriction"=>{"length"=>12, "pattern"=>"([0-9]{1}[1-9]{1}|[1-9]{1}[0-9]{1})[0-9]{10}"}}}]}], "attributes"=>[{"type"=>"string", "restriction"=>{"length"=>10, "pattern"=>"(((0[1-9]{1}|[1-2]{1}[0-9]{1})\.(0[1-9]{1}|1[0-2]{1}))|((30)\.(0[1,3-9]{1}|1[0-2]{1}))|((31)\.(0[1,3,5,7,8]{1}|1[0,2]{1})))\.(19[0-9]{2}|20[0-9]{2})"}, "name"=>"ДатаНа", "use"=>"required"}]}]}], "attributes"=>[{"type"=>"string", "restriction"=>{"enumeration"=>["4.02"], "minlength"=>1, "maxlength"=>5}, "name"=>"ВерсФорм", "use"=>"required"}, {"type"=>"string", "restriction"=>{"length"=>36}, "name"=>"ИдЗапросП", "use"=>"optional"}]}
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
      sm.get_child("ЗапросНП").attribute("ДатаНа").set "09.12.1990"
      sm.valid?.should be_false
      sm.errors["SendRequestRq"]["MessageData"]["AppData"]["Документ"].should_not include("ЗапросНП")

      sm.get_child("ИННЮЛ").set ""
      sm.get_child("ЗапросНП").attribute("ДатаНа").set ""

      # check full fill
      sm.fill_test

      sm.valid?.should be_true
      sm.errors.should eql({})

      # puts sm.as_hash

    end

    it "generate fault" do
      hash =  {"name"=>"Fault", "type"=>"element", "namespace" => "http://schemas.xmlsoap.org/soap/envelope/", "children"=>[
                {"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[
                  {"name"=>"faultcode", "type"=>"element", "value"=>{"type"=>"QName", "restriction"=>{}}},
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
          xml << sm.get_child("AppData").children.first.as_xsd
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
          sm_unb.load_from_xml File.read File.dirname(__FILE__) + "/example.xml"
          inns = sm_unb.search_child("ИННЮЛ")
          inns.size.should eql(3)
          inns.shift.value.get.should eql("9999999999")
          inns.shift.value.get.should eql("8888888888")
          inns.shift.value.get.should eql("7777777777")

          sm_unb.load_from_xml File.read File.dirname(__FILE__) + "/example1.xml"
          inns = sm_unb.search_child("ИННЮЛ")
          inns.size.should eql(1)
          inns.shift.value.get.should eql("9999999999")
        end

        it "hash" do
          sm_unb.load_from_hash ({"SendRequestRq"=>{"Message"=>{"Sender"=>{"Code"=>"", "Name"=>""}, "Recipient"=>{"Code"=>"", "Name"=>""}, "Originator"=>{"Code"=>"", "Name"=>""}, "TypeCode"=>"GSRV", "Date"=>"", "RequestIdRef"=>"", "OriginRequestIdRef"=>"", "ServiceCode"=>"", "CaseNumber"=>""}, "MessageData"=>{"AppData"=>{"Документ"=>{"@attr"=>{"ВерсФорм"=>"4.02", "ИдЗапросП"=>"999999999999999999999999999999999999"}, "СвЮЛ"=>{"@attr"=>{"НаимЮЛ"=>"9", "ИННЮЛ"=>"9999999999", "ОГРН"=>"9999999999999"}}, "ЗапросНП"=>[{"@attr"=>{"ДатаНа"=>"9999999999"}, "ИННЮЛ"=>"9999999999"}, {"@attr"=>{"ДатаНа"=>"8888888888"}, "ИННЮЛ"=>"8888888888"}, {"@attr"=>{"ДатаНа"=>"7777777777"}, "ИННЮЛ"=>"7777777777"}]}}, "AppDocument"=>{"BinaryData"=>"", "Reference"=>{"Include"=>{"@attr"=>{"href"=>""}}}, "DigestValue"=>""}}}})
          inns = sm_unb.search_child("ИННЮЛ")
          inns.size.should eql(3)
          sm_unb.to_hash.should eql({"SendRequestRq"=>{"Message"=>{"Sender"=>{"Code"=>"", "Name"=>""}, "Recipient"=>{"Code"=>"", "Name"=>""}, "Originator"=>{"Code"=>"", "Name"=>""}, "TypeCode"=>"GSRV", "Date"=>"", "RequestIdRef"=>"", "OriginRequestIdRef"=>"", "ServiceCode"=>"", "CaseNumber"=>""}, "MessageData"=>{"AppData"=>{"Документ"=>{"@attr"=>{"ВерсФорм"=>"4.02", "ИдЗапросП"=>"999999999999999999999999999999999999"}, "СвЮЛ"=>{"@attr"=>{"НаимЮЛ"=>"9", "ИННЮЛ"=>"9999999999", "ОГРН"=>"9999999999999"}}, "ЗапросНП"=>[{"@attr"=>{"ДатаНа"=>"9999999999"}, "ИННЮЛ"=>"9999999999"}, {"@attr"=>{"ДатаНа"=>"8888888888"}, "ИННЮЛ"=>"8888888888"}, {"@attr"=>{"ДатаНа"=>"7777777777"}, "ИННЮЛ"=>"7777777777"}]}}, "AppDocument"=>{"BinaryData"=>"", "Reference"=>{"Include"=>{"@attr"=>{"href"=>""}}}, "DigestValue"=>""}}}})
          inns.shift.value.get.should eql("9999999999")
          inns.shift.value.get.should eql("8888888888")
          inns.shift.value.get.should eql("7777777777")

          sm_unb.load_from_hash ({"SendRequestRq"=>{"Message"=>{"Sender"=>{"Code"=>"", "Name"=>""}, "Recipient"=>{"Code"=>"", "Name"=>""}, "Originator"=>{"Code"=>"", "Name"=>""}, "TypeCode"=>"GSRV", "Date"=>"", "RequestIdRef"=>"", "OriginRequestIdRef"=>"", "ServiceCode"=>"", "CaseNumber"=>""}, "MessageData"=>{"AppData"=>{"Документ"=>{"@attr"=>{"ВерсФорм"=>"4.02", "ИдЗапросП"=>"999999999999999999999999999999999999"}, "СвЮЛ"=>{"@attr"=>{"НаимЮЛ"=>"9", "ИННЮЛ"=>"9999999999", "ОГРН"=>"9999999999999"}}, "ЗапросНП"=>{"@attr"=>{"ДатаНа"=>"9999999999"}, "ИННЮЛ"=>"9999999999"}}}, "AppDocument"=>{"BinaryData"=>"", "Reference"=>{"Include"=>{"@attr"=>{"href"=>""}}}, "DigestValue"=>""}}}})
          inns = sm_unb.search_child("ИННЮЛ")
          inns.size.should eql(1)
          inns.shift.value.get.should eql("9999999999")
        end

      end

    end


  end



end
