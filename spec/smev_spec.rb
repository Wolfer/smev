require 'smev'
require 'spec_helper'

describe Smev::Message do   

  let(:xsd) do
    wsdl = WSDL::Importer.import( "file://" + File.dirname(__FILE__) + "/test_xsd/wsdl" )
    wsdl.find_by_action wsdl.soap_actions.first
  end

  describe "created" do

    it 'from xsd' do
      sm = Smev::Message.new xsd
      sm.struct.should_not be_empty
      #FIXME add as_xsd checking
    end

    it 'from hash' do
      hash = {"name"=>"SendRequestRq", "type"=>"element", "children"=>[{"name"=>"Sequence", "type"=>"sequence", "children"=>[{"name"=>"Message", "type"=>"element", "children"=>[{"name"=>"Sequence", "type"=>"sequence", "children"=>[{"name"=>"Sender", "type"=>"element", "children"=>[{"name"=>"Sequence", "type"=>"sequence", "children"=>[{"name"=>"Code", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}}, {"name"=>"Name", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}}]}]}, {"name"=>"Recipient", "type"=>"element", "children"=>[{"name"=>"Sequence", "type"=>"sequence", "children"=>[{"name"=>"Code", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}}, {"name"=>"Name", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}}]}]}, {"name"=>"Originator", "type"=>"element", "children"=>[{"name"=>"Sequence", "type"=>"sequence", "children"=>[{"name"=>"Code", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}}, {"name"=>"Name", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}}]}]}, {"name"=>"TypeCode", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}}, {"name"=>"Date", "type"=>"element", "value"=>{"type"=>"dateTime", "restrictions"=>{}}}, {"name"=>"RequestIdRef", "type"=>"element", "min_occurs"=>0, "value"=>{"type"=>"string", "restrictions"=>{}}}, {"name"=>"OriginRequestIdRef", "type"=>"element", "min_occurs"=>0, "value"=>{"type"=>"string", "restrictions"=>{}}}, {"name"=>"ServiceCode", "type"=>"element", "min_occurs"=>0, "value"=>{"type"=>"string", "restrictions"=>{}}}, {"name"=>"CaseNumber", "type"=>"element", "min_occurs"=>0, "value"=>{"type"=>"string", "restrictions"=>{}}}]}]}, {"name"=>"MessageData", "type"=>"element", "children"=>[{"name"=>"Sequence", "type"=>"sequence", "children"=>[{"name"=>"AppData", "type"=>"element", "min_occurs"=>0, "children"=>[{"name"=>"Sequence", "type"=>"sequence", "children"=>[{"name"=>"Документ", "type"=>"element", "children"=>[{"name"=>"Sequence", "type"=>"sequence", "children"=>[{"name"=>"СвЮЛ", "type"=>"element", "attributes"=>[{"type"=>"string", "restrictions"=>{"minlength"=>1, "maxlength"=>1000}, "name"=>"НаимЮЛ", "use"=>"required"}, {"type"=>"string", "restrictions"=>{"length"=>10, "pattern"=>"([0-9]{1}[1-9]{1}|[1-9]{1}[0-9]{1})[0-9]{8}"}, "name"=>"ИННЮЛ", "use"=>"required"}, {"type"=>"string", "restrictions"=>{"length"=>13, "pattern"=>"[0-9]{13}"}, "name"=>"ОГРН", "use"=>"required"}]}, {"name"=>"ЗапросНП", "type"=>"element", "children"=>[{"name"=>"Choice", "type"=>"choice", "children"=>[{"name"=>"ИННЮЛ", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{"length"=>10, "pattern"=>"([0-9]{1}[1-9]{1}|[1-9]{1}[0-9]{1})[0-9]{8}"}}}, {"name"=>"ИННФЛ", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{"length"=>12, "pattern"=>"([0-9]{1}[1-9]{1}|[1-9]{1}[0-9]{1})[0-9]{10}"}}}]}], "attributes"=>[{"type"=>"string", "restrictions"=>{"length"=>10, "pattern"=>"(((0[1-9]{1}|[1-2]{1}[0-9]{1})\.(0[1-9]{1}|1[0-2]{1}))|((30)\.(0[1,3-9]{1}|1[0-2]{1}))|((31)\.(0[1,3,5,7,8]{1}|1[0,2]{1})))\.(19[0-9]{2}|20[0-9]{2})"}, "name"=>"ДатаНа", "use"=>"required"}]}]}], "attributes"=>[{"type"=>"string", "restrictions"=>{"enumeration"=>["4.02"], "minlength"=>1, "maxlength"=>5}, "name"=>"ВерсФорм", "use"=>"required"}, {"type"=>"string", "restrictions"=>{"length"=>36}, "name"=>"ИдЗапросП", "use"=>"optional"}]}]}]}, {"name"=>"AppDocument", "type"=>"element", "min_occurs"=>0, "children"=>[{"name"=>"Sequence", "type"=>"sequence", "children"=>[{"name"=>"BinaryData", "type"=>"element", "value"=>{"type"=>"base64Binary", "restrictions"=>{}}}, {"name"=>"Reference", "type"=>"element", "children"=>[{"name"=>"Sequence", "type"=>"sequence", "children"=>[{"name"=>"Include", "type"=>"element", "children"=>[{"name"=>"Sequence", "type"=>"sequence"}], "attributes"=>[{"type"=>"anyURI", "restrictions"=>{}, "name"=>"href", "use"=>"required"}]}]}]}, {"name"=>"DigestValue", "type"=>"element", "value"=>{"type"=>"base64Binary", "restrictions"=>{}}}]}]}]}]}]}]}
      #{"name"=>"Документ", "type"=>"element", "children"=>[{"name"=>"Sequence", "type"=>"sequence", "children"=>[{"name"=>"СвЮЛ", "type"=>"element", "attributes"=>[{"type"=>"string", "restrictions"=>{"minlength"=>1, "maxlength"=>1000}, "name"=>"НаимЮЛ", "use"=>"required"}, {"type"=>"string", "restrictions"=>{"length"=>10, "pattern"=>"([0-9]{1}[1-9]{1}|[1-9]{1}[0-9]{1})[0-9]{8}"}, "name"=>"ИННЮЛ", "use"=>"required"}, {"type"=>"string", "restrictions"=>{"length"=>13, "pattern"=>"[0-9]{13}"}, "name"=>"ОГРН", "use"=>"required"}]}, {"name"=>"ЗапросНП", "type"=>"element", "children"=>[{"name"=>"Choice", "type"=>"choice", "children"=>[{"name"=>"ИННЮЛ", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{"length"=>10, "pattern"=>"([0-9]{1}[1-9]{1}|[1-9]{1}[0-9]{1})[0-9]{8}"}}}, {"name"=>"ИННФЛ", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{"length"=>12, "pattern"=>"([0-9]{1}[1-9]{1}|[1-9]{1}[0-9]{1})[0-9]{10}"}}}]}], "attributes"=>[{"type"=>"string", "restrictions"=>{"length"=>10, "pattern"=>"(((0[1-9]{1}|[1-2]{1}[0-9]{1})\.(0[1-9]{1}|1[0-2]{1}))|((30)\.(0[1,3-9]{1}|1[0-2]{1}))|((31)\.(0[1,3,5,7,8]{1}|1[0,2]{1})))\.(19[0-9]{2}|20[0-9]{2})"}, "name"=>"ДатаНа", "use"=>"required"}]}]}], "attributes"=>[{"type"=>"string", "restrictions"=>{"enumeration"=>["4.02"], "minlength"=>1, "maxlength"=>5}, "name"=>"ВерсФорм", "use"=>"required"}, {"type"=>"string", "restrictions"=>{"length"=>36}, "name"=>"ИдЗапросП", "use"=>"optional"}]}
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

      sm.errors["getFNS"]["MessageData"]["AppData"]["Data"]["Документ"].should_not include("ЗапросНП")

      sm.get_child("ИННЮЛ").set ""
      sm.get_child("ЗапросНП").attribute("ДатаНа").set ""

      # check full fill
      sm.fill_test

      sm.valid?.should be_true
      sm.errors.should eql({})

      # puts sm.as_hash

    end

    it 'may not filling min_occurs zero' do
      sm.valid?.should be_false
      sm.errors.should_not eql({})
      sm.get_child("MessageData").fill_test
      sm.get_child("Message").load_from_hash "Message" =>{
        "Sender" => {"Code" => "FNS001611", "Name" => "FNS" }, 
        "Recipient" => { "Code" => "MB0101611", "Name" => "Minstroi" },
        "ServiceName" => "MB0101611", 
        "TypeCode" => "GSRV", 
        "Status" => "REQUEST", 
        "Date" => Time.now.xmlschema, 
        "ExchangeType" => "2", 
      }
      sm.valid?.should be_true
      sm.errors.should_not eql({})
      sm.to_xml(false).index("Originator").should be_nil, "Must delete from xml not valid element with min_occurs zero"
    end

    it 'raise when extra element into sequence' do
      hash =  {"name"=>"fault", "type"=>"element", "namespace" => "http://schemas.xmlsoap.org/soap/envelope/", "children"=>[
        {"name"=>"Sequence", "type"=>"sequence", "children"=>[
          {"name"=>"string", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}},
          {"name"=>"code", "type"=>"element", "min_occurs" => 0, "value"=>{"type"=>"string", "restrictions"=>{}}}          
        ]}
      ]}
      sm = Smev::Message.new hash
      sm.load_from_xml("<Body><fault><string>123</string><extra>123</extra></fault></Body>").should be_false
      sm.errors["load_from_xml"].should eql("Element extra not expect here!")
    end

    it 'found element into sub-complex-type' do
      hash =  {"name"=>"fault", "type"=>"element", "namespace" => "http://schemas.xmlsoap.org/soap/envelope/", "children"=>[
        {"name"=>"Sequence", "type"=>"sequence", "children"=>[
          {"name"=>"first", "type"=>"element", "min_occurs" => 0, "value"=>{"type"=>"string", "restrictions"=>{}}},
          {"name"=>"Sequence", "type"=>"sequence", "children"=>[
            {"name"=>"string", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}}
          ]}
        ]}
      ]}
      sm = Smev::Message.new hash
      sm.load_from_xml("<Body><fault><string>123</string></fault></Body>").should be_true
    end

    it 'non find element in next sequence' do
      hash =  {"name"=>"fault", "type"=>"element", "namespace" => "http://schemas.xmlsoap.org/soap/envelope/", "children"=>[
        {"name"=>"Sequence", "type"=>"sequence", "children"=>[
          {"name"=>"Sequence", "type"=>"sequence", "children"=>[
            {"name"=>"string", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}}
          ]},
          {"name"=>"Sequence", "type"=>"sequence", "children"=>[
            {"name"=>"code", "type"=>"element", "min_occurs" => 0, "value"=>{"type"=>"string", "restrictions"=>{}}}          
          ]}
        ]}
      ]}
      sm = Smev::Message.new hash
      sm.load_from_xml("<Body><fault><string>123</string></fault></Body>").should be_true
    end

    it "generate fault" do
      hash =  {"name"=>"Fault", "type"=>"element", "namespace" => "http://schemas.xmlsoap.org/soap/envelope/", "children"=>[
                {"name"=>"Sequence", "type"=>"sequence", "children"=>[
                  {"name"=>"faultcode", "type"=>"element", "value"=>{"type"=>"QName", "restrictions"=>{}}},
                  {"name"=>"faultstring", "type"=>"element", "value"=>{"value"=> "fault", "type"=>"string", "restrictions"=>{}}}
                ]}
              ]}

      sm = Smev::Message.new hash
      sm.fill_test
      sm.to_xml(false).should_not be_blank
    end

    it 'disable AppDocument' do
      sm.get_child("AppDocument").should_not be_nil
      sm.remove_appdoc
      sm.get_child("AppDocument").should be_nil
    end

    it "dupable" do
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

    describe "transfert" do

      it "files" do
        sm.fill_test
        source = Dir.glob(File.dirname(__FILE__) + "/test_xsd/*")
        sm.files += source
        sm.load_from_xml sm.to_xml(false)

        sm.files = []
        Dir.mktmpdir do |dir|
          sm.get_appdoc dir
          sm.files.size.should eql(source.size)
          sm.files.each do |file|
            next if File.basename(file["Name"]) =~ /req_[^\.]+\.xml/
            src = source.find{|s| s.index(File.basename(file["Name"])) }
            File.read(file["Name"]).should eql(File.read(src))
          end
        end
      end

      it "information" do
        sm.fill_test
        source = Dir.glob(File.dirname(__FILE__) + "/test_xsd/*")
        sm.attachment_schema = {"name"=>"PeopleInfo", "type"=>"element", "namespace"=>"http://rnd-soft.ru", "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[
          {"name"=>"FIO", "type"=>"element", "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[
            {"name"=>"Surname", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{"length"=>"1"}}}, 
            {"name"=>"Name", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{"length"=>"1"}}}, 
            {"name"=>"Patronymic", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{"length"=>"1"}}}
        ]}]}]}]}
        sm.attachment_schema.fill_test
        start_hash = sm.attachment_schema.to_hash

        sm.load_from_xml sm.to_xml(false)

        Dir.mktmpdir { |dir| sm.get_appdoc dir }
        sm.attachment_schema.to_hash.should eql(start_hash)
      end

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
          xml << sm.get_child("AppData").as_xsd
        end

        tmp_file = Tempfile.new "xsd"
        tmp_file.write xml.target!
        tmp_file.close
        new_sm = Smev::Message.new WSDL::Importer.import( "file://" + tmp_file.path ).elements.first
        new_sm.fill_test
        sm.fill_test
        xml_sm = sm.get_child("AppData").to_xml([])
        xml_new_sm = new_sm.struct.first.to_xml([])
        xml_sm.should eql(xml_new_sm)
      end

    end

    it "signed and verify" do
      sm.fill_test
      xml = sm.to_xml

      noko = Nokogiri::XML::Document.parse(xml)
      noko.search_child("SignatureValue").should_not be_empty
      noko.search_child("SignatureValue").first.children.first.to_s.should_not be_empty

      noko.search_child("SignatureValue").first.children.first.content = "wrong_value"
      bad_xml = noko.to_s
      sm.load_from_xml(bad_xml).should be_false
      sm.errors["load_from_xml"].should be_present
      
      sm.load_from_xml(xml).should be_true

    end


    describe 'import from' do

      it 'xml' do
          sm.fill_test
          xml = sm.to_xml(false)
          sm.load_from_xml(xml).should be_true
      end

      it 'hash' do
          sm.fill_test
          hash = sm.to_hash
          sm.load_from_hash(hash).should be_true
      end

      describe '(unbounded)' do
        let(:sm_unb) do
          wsdl = WSDL::Importer.import( "file://" + File.dirname(__FILE__) + "/test_xsd_unbounded/wsdl" )
          Smev::Message.new wsdl.find_by_action(wsdl.soap_actions.first)
        end

        it "xml" do
          sm_unb.load_from_xml File.read(File.dirname(__FILE__) + "/example.xml")
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
          sm_unb.load_from_hash ({"SendRequestRq"=>{"Message"=>{"Sender"=>{"Code"=>"", "Name"=>""}, "Recipient"=>{"Code"=>"", "Name"=>""}, "Originator"=>{"Code"=>"", "Name"=>""}, "TypeCode"=>"GSRV", "Date"=>"", "RequestIdRef"=>"", "OriginRequestIdRef"=>"", "ServiceCode"=>"", "CaseNumber"=>""}, "MessageData"=>{"AppData"=>{"Документ"=>{"@attr"=>{"ВерсФорм"=>"4.02", "ИдЗапросП"=>"999999999999999999999999999999999999"}, "СвЮЛ"=>{"@attr"=>{"НаимЮЛ"=>"9", "ИННЮЛ"=>"9999999999", "ОГРН"=>"9999999999999"}}, "ЗапросНП"=>[{"@attr"=>{"ДатаНа"=>"9999999999"}, "ИННЮЛ"=>"9999999999"}, {"@attr"=>{"ДатаНа"=>"8888888888"}, "ИННЮЛ"=>"8888888888"}, {"@attr"=>{"ДатаНа"=>"7777777777"}, "ИННЮЛ"=>"7777777777"}]}}, "AppDocument"=>{"BinaryData"=>""}}}})
          inns = sm_unb.search_child("ИННЮЛ")
          inns.size.should eql(3)
          sm_unb.to_hash.should eql({"SendRequestRq"=>{"Message"=>{"Sender"=>{"Code"=>"", "Name"=>""}, "Recipient"=>{"Code"=>"", "Name"=>""}, "Originator"=>{"Code"=>"", "Name"=>""}, "TypeCode"=>"GSRV", "Date"=>"", "RequestIdRef"=>"", "OriginRequestIdRef"=>"", "ServiceCode"=>"", "CaseNumber"=>""}, "MessageData"=>{"AppData"=>{"Документ"=>{"@attr"=>{"ВерсФорм"=>"4.02", "ИдЗапросП"=>"999999999999999999999999999999999999"}, "СвЮЛ"=>{"@attr"=>{"НаимЮЛ"=>"9", "ИННЮЛ"=>"9999999999", "ОГРН"=>"9999999999999"}}, "ЗапросНП"=>[{"@attr"=>{"ДатаНа"=>"9999999999"}, "ИННЮЛ"=>"9999999999"}, {"@attr"=>{"ДатаНа"=>"8888888888"}, "ИННЮЛ"=>"8888888888"}, {"@attr"=>{"ДатаНа"=>"7777777777"}, "ИННЮЛ"=>"7777777777"}]}}, "AppDocument"=>{"BinaryData"=>""}}}})
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

    describe 'missing element for <all>' do
      it 'min_occurs 0' do
        hash =  {"name"=>"fault", "type"=>"element", "namespace" => "http://schemas.xmlsoap.org/soap/envelope/", "children"=>[
          {"name"=>"All", "type"=>"all", "children"=>[
            {"name"=>"code", "type"=>"element", "min_occurs" => 0, "value"=>{"type"=>"string", "restrictions"=>{}}},
            {"name"=>"string", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}}
          ]}
        ]}
        sm = Smev::Message.new hash
        sm.load_from_xml("<Body><fault><string>123</string></fault></Body>").should be_true
        sm.load_from_xml("<Body><fault><code>123</code></fault></Body>").should be_false
      end

    end

    it 'choice right to_xml with min_occurs 0' do
      hash =  {"name"=>"fault", "type"=>"element", "namespace" => "http://schemas.xmlsoap.org/soap/envelope/", "children"=>[
        {"name"=>"Sequence", "type"=>"sequence", "children"=>[
          {"name"=>"text", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}},
          {"name"=>"Choice", "type"=>"choice", "children"=>[
            {"name"=>"string", "type"=>"element", "min_occurs" => 0, "children"=>[
              {"name"=>"Sequence", "type"=>"sequence", "children"=>[
                {"name"=>"text", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}}]}]}
          ]}
        ]}
      ]}
      sm = Smev::Message.new hash
      sm.get_child("text").set "123"
      sm.to_xml(false).should be_a(String)
    end


  end



end
