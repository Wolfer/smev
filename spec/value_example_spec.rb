require 'smev'
require 'spec_helper'

describe Smev::Message do

  describe 'value example' do

    it 'validatable' do
      hash = {"name"=>"fault", "type"=>"element", "namespace" => "http://schemas.xmlsoap.org/soap/envelope/", "children"=>[
        {"name"=>"Sequence", "type"=>"sequence", "children"=>[
          {"name"=>"first", "type"=>"element", "value"=>{"type"=>"string", "example" => "asd", "restrictions"=>{}}},
          {"name"=>"regexp", "type"=>"element", "value"=>{"type"=>"string", "example" => "asd", "restrictions"=>{"pattern"=>"[0-9]{2}"}}},
          {"name"=>"length", "type"=>"element", "value"=>{"type"=>"string", "example" => "asd", "restrictions"=>{"length"=>4}}},
          {"name"=>"empty", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}}
        ]}
      ]}
      sm = Smev::Message.new hash
      sm.fill_test
      values = sm.to_hash(false)["fault"]
      values["first"].should eql("asd")
      values["regexp"].should eql("99")
      values["length"].should eql("asd9")
      values["empty"].should eql("example")
      seq = sm.as_hash.first["children"].first["children"]
      seq[0]["value"]["example"].should eql("asd")
      seq[1]["value"]["example"].should eql("asd")
      seq[3]["value"]["example"].should be_nil
    end

  end

end
