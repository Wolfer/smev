module Features

	def self.call_shell cmd, input
		open('| '+cmd, 'rb+:UTF-8') do |p|
			p.write input
			p.close_write
			p.read
		end
	end

	def self.write_tmp input, name = 'sign'
		tmp_file = Tempfile.new name
		tmp_file.binmode.write input
		tmp_file.close
		tmp_file
	end

	def self.build_xml
		xml = Builder::XmlMarkup.new
		if block_given?
			yield xml
			xml.target!
		else
			xml
		end
	end

end
