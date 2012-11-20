xml = Builder::XmlMarkup.new
xml.instruct!
xml.tag! "soap:Envelope", { "xmlns:soap" => "http://schemas.xmlsoap.org/soap/envelope/",
						 "xmlns:wsse" => "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd",
						 "xmlns:wsu" => "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd",
						 "xmlns:ds" => "http://www.w3.org/2000/09/xmldsig#"}.merge(namespaces) do
	xml.tag! "soap:Body", "wsu:Id" => "body" do
		xml << result
	end  
end
xml.target!