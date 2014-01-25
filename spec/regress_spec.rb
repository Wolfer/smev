require 'smev'
require 'spec_helper'

describe Smev::Message do   

  it 'inherite namespace to child' do
    hash =  {"name"=>"fault", "type"=>"element", "namespace" => "http://schemas.xmlsoap.org/soap/envelope/", "children"=>[
      {"name"=>"Sequence", "type"=>"sequence", "children"=>[
        {"name"=>"first", "type"=>"element", "min_occurs" => 0, "value"=>{"type"=>"string", "restrictions"=>{}}},
        {"name"=>"Sequence", "type"=>"sequence", "children"=>[
          {"name"=>"string", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}}
        ]}
      ]}
    ]}
    sm = Smev::Message.new hash
    sm.get_child("first").namespace.should be_eql("http://schemas.xmlsoap.org/soap/envelope/")
  end


end
