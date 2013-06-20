require 'smev'
require 'spec_helper'

describe Smev::Message do   
  describe "can" do

    it 'choose fill branch of choice' do
      hash =  {"name"=>"Test", "type"=>"element", "namespace" => "http://schemas.xmlsoap.org/soap/envelope/", "children"=>[
              {"name"=>"Choice", "type"=>"choice", "children"=>[
                {"name"=>"first", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}},
                {"name"=>"second", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}}
              ]}
            ]}

      sm = Smev::Message.new hash
      sm.valid?.should be_false
      sm.get_child("second").set ''
      sm.valid?.should be_true
      sm.to_xml(false).should match('second')
    end

    it 'escaping " in attribute' do
      hash =  {"name"=>"test_elem", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}, "attributes"=>[{"type"=>"string", "restrictions"=>{}, "name"=>"test_attr", "use"=>"required"}] }

      sm = Smev::Message.new hash
      sm.get_child("test_elem").attribute("test_attr").set ' company "Company" '
      sm.get_child("test_elem").set ''
      sm2 = Smev::Message.new hash
      sm2.load_from_xml sm.to_xml
      sm2.get_child("test_elem").attribute("test_attr").get.should eql(sm.get_child("test_elem").attribute("test_attr").get)
    end

    describe "min_occurs for" do
      let(:xml){ '<x:test xmlns:x="test"><anything>asd</anything></x:test>' }

      it 'choice' do
        hash =  {"name"=>"test", "type"=>"element", "namespace" => "http://schemas.xmlsoap.org/soap/envelope/", "children"=>[
              {"name"=>"Sequence", "type"=>"sequence", "children"=>[
                {"name"=>"anything", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}},
                {"name"=>"Choice", "type"=>"choice", "children"=>[
                  {"name"=>"first", "type"=>"element", "min_occurs" => 0, "value"=>{"type"=>"string", "restrictions"=>{}}},
                  {"name"=>"second", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}}
                ]}
              ]}
            ]}
        sm = Smev::Message.new hash
        doc = Nokogiri::XML::Document.parse(xml).children
        sm.struct.first.load_from_nokogiri doc.first
        sm.valid?.should be_true
      end

      it 'sequence' do
        hash =  {"name"=>"test", "type"=>"element", "namespace" => "http://schemas.xmlsoap.org/soap/envelope/", "children"=>[
              {"name"=>"Sequence", "type"=>"sequence", "children"=>[
                {"name"=>"anything", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}},
                {"name"=>"Sequence", "type"=>"sequence", "children"=>[
                  {"name"=>"first", "type"=>"element", "min_occurs" => 0, "value"=>{"type"=>"string", "restrictions"=>{}}},
                  {"name"=>"second", "type"=>"element", "min_occurs" => 0, "value"=>{"type"=>"string", "restrictions"=>{}}}
                ]}
              ]}
            ]}
        sm = Smev::Message.new hash
        doc = Nokogiri::XML::Document.parse(xml).children
        sm.struct.first.load_from_nokogiri doc.first
        sm.valid?.should be_true
      end

    end


    it 'stop iteration when in choice/sequence min_occurs 0 and no element' do
      hash =  {"name"=>"test", "type"=>"element", "namespace" => "http://schemas.xmlsoap.org/soap/envelope/", "children"=>[
            {"name"=>"Sequence", "type"=>"sequence", "children"=>[
              {"name"=>"anything", "type"=>"element", "min_occurs" => 0, "value"=>{"type"=>"string", "restrictions"=>{}}},
              {"name"=>"Choice", "type"=>"choice", "children"=>[
                {"name"=>"first", "type"=>"element", "min_occurs" => 0, "value"=>{"type"=>"string", "restrictions"=>{}}},
                {"name"=>"second", "type"=>"element", "min_occurs" => 0, "value"=>{"type"=>"string", "restrictions"=>{}}}
              ]}
            ]}
          ]}
      sm = Smev::Message.new hash
      doc = Nokogiri::XML::Document.parse('<x:test xmlns:x="test"/>').children
      sm.struct.first.load_from_nokogiri doc.first
      sm.valid?.should be_true
    end

    it 'inheritence restricted type' do
      w = WSDL::Importer.import( "file://" + File.dirname(__FILE__) + "/restriction_base.xsd" )
      e = Smev::XSD::Element.build_from_xsd w.elements.first
      e.as_xsd.should_not match('xs:cc')
      e.as_xsd.should match('value="2"')

      doc = Nokogiri::XML::Document.parse '<tns:a xmlns:tns="http://ws.unisoft/EGRNXX/ResponseVIPFL" reg="00"/>'
      e.load_from_nokogiri doc.children.first
      e.valid?.should be_true

      doc = Nokogiri::XML::Document.parse '<tns:a xmlns:tns="http://ws.unisoft/EGRNXX/ResponseVIPFL" reg="001"/>'
      e.load_from_nokogiri doc.children.first
      e.valid?.should be_false

    end


    it 'failed last choice into sequence' do
      hash =  {"name"=>"test", "type"=>"element", "namespace" => "http://schemas.xmlsoap.org/soap/envelope/", "children"=>[
                {"name"=>"Sequence", "type"=>"sequence", "children"=>[
                  {"name"=>"Choice", "type"=>"choice", "children"=>[
                    {"name"=>"first", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}}
                  ]}
                ]}
              ]}
      sm = Smev::Message.new hash
      doc = Nokogiri::XML::Document.parse('<x:test xmlns:x="test"><first>1</first></x:test>').children
      sm.struct.first.load_from_nokogiri doc.first
      sm.valid?.should be_true
    end

    it 'restricted by array of pattern' do
      hash =  {"name"=>"first", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{ "pattern" => ["[0-9]{12}", "[0-9]{10}"] }}}
      sm = Smev::Message.new hash
      f = sm.get_child("first")
      f.set "1234567890"
      f.valid?.should be_true
      f.set "123456789012"
      f.valid?.should be_true
      f.set "12345678901"
      f.valid?.should be_false
    end

  end

end