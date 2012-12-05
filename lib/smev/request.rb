module Smev
	class Request

		def self.do wsdl_url, soap_action, body
			http = HTTPI::Request.new
			http.url = wsdl_url
			http.headers["SOAPAction"] = soap_action
			http.headers["Content-Type"] = "application/soap+xml;charset=UTF-8"
			http.headers["Content-Length"] = body.bytesize.to_s
			http.body = body
			HTTPI.post(http)
		end

	end
end