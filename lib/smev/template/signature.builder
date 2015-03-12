xml = Builder::XmlMarkup.new
xml.tag! "soap:Header", "xmlns:soap" => "http://schemas.xmlsoap.org/soap/envelope/" do
	xml.tag! "wsse:Security", "xmlns:soap" => "http://schemas.xmlsoap.org/soap/envelope/", "soap:actor" => "http://smev.gosuslugi.ru/actors/smev", "xmlns:wsse" => NAMESPACES["wsse"] do
		xml.tag! "ds:Signature", "xmlns:ds" => NAMESPACES["ds"] do
			xml.tag! "ds:SignedInfo" do
				xml.tag! "ds:CanonicalizationMethod", "Algorithm" => "http://www.w3.org/2001/10/xml-exc-c14n#"
				xml.tag! "ds:SignatureMethod", "Algorithm" => "http://www.w3.org/2001/04/xmldsig-more#gostr34102001-gostr3411"
				xml.tag! "ds:Reference", "URI" => "#body"  do
					xml.tag! "ds:Transforms"  do
						xml.tag! "ds:Transform", "Algorithm" => "http://www.w3.org/2000/09/xmldsig#enveloped-signature"
						xml.tag! "ds:Transform", "Algorithm" => "http://www.w3.org/2001/10/xml-exc-c14n#"
					end
					xml.tag! "ds:DigestMethod", "Algorithm" => "http://www.w3.org/2001/04/xmldsig-more#gostr3411"
					xml.tag! "ds:DigestValue"
				end
			end
			xml.tag! "ds:SignatureValue"
			xml.tag! "ds:KeyInfo" do
				xml.tag! "wsse:SecurityTokenReference" do
					xml.tag! "wsse:Reference", "URI" => "#CertId", "ValueType" => "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-x509-token-profile-1.0#X509v3"
				end
			end
		end
		xml.tag! "wsse:BinarySecurityToken",  "EncodingType" => "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary", 
									"ValueType" => "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-x509-token-profile-1.0#X509v3", 
									"wsu:Id" => "CertId" do
			"CertificateBody"		
		end
	end
end
xml.target!