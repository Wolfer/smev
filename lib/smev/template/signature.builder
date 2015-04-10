xml =  Builder::XmlMarkup.new
xml.tag! "--WSSE--:Security", (opts[:nss]||{}).merge(
                                "--SOAP--:actor" => "http://smev.gosuslugi.ru/actors/smev") do

  xml.tag! "--DS--:Signature" do
    xml.tag! "--DS--:SignedInfo" do
      xml.tag! "--DS--:CanonicalizationMethod", "Algorithm" => "http://www.w3.org/2001/10/xml-exc-c14n#"
      xml.tag! "--DS--:SignatureMethod", "Algorithm" => "http://www.w3.org/2001/04/xmldsig-more#gostr34102001-gostr3411"
      xml.tag! "--DS--:Reference", "URI" => "#body"  do
        xml.tag! "--DS--:Transforms"  do
          xml.tag! "--DS--:Transform", "Algorithm" => "http://www.w3.org/2000/09/xmldsig#enveloped-signature"
          xml.tag! "--DS--:Transform", "Algorithm" => "http://www.w3.org/2001/10/xml-exc-c14n#"
        end
        xml.tag! "--DS--:DigestMethod", "Algorithm" => "http://www.w3.org/2001/04/xmldsig-more#gostr3411"
        xml.tag! "--DS--:DigestValue"
      end
    end
    xml.tag! "--DS--:SignatureValue"
    xml.tag! "--DS--:KeyInfo" do
      xml.tag! "--WSSE--:SecurityTokenReference" do
        xml.tag! "--WSSE--:Reference", "URI" => "#CertId", "ValueType" => "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-x509-token-profile-1.0#X509v3"
      end
    end
  end
  xml.tag! "--WSSE--:BinarySecurityToken",  "EncodingType" => "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary", 
                "ValueType" => "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-x509-token-profile-1.0#X509v3", 
                "--WSU--:Id" => "CertId" do
    "CertificateBody"   
  end
end
xml.target!