require 'net/http'
module Smev
  class Downloader

    def initialize  dir_path
      @dir_path = dir_path
    end

    def run wsdl_url
      FileUtils.mkdir_p @dir_path, :mode => 0777 unless File.exist? @dir_path
      @imports = {}
      get_remote wsdl_url do |body|
        process4xsd body, 'xsd', wsdl_url
        File.open( @dir_path+"/wsdl", 'w' ){|f| f.write body }
      end
      true
    end

  private

    def process4xsd text, name, root_url
      text.scan(/(schemaLocation=\"([^\"]+)\")/i).each_with_index do |match, i|
        unless @imports.include? match.last
          get_remote match.last, root_url do |body|
            child = "#{name}-#{i}"
            @imports[match.last] = child
            process4xsd body, child, root_url
            File.open( @dir_path+"/#{child}", 'w' ){|f| f.write body } 
          end
        end
        text.sub! match.first, "schemaLocation=\"#{@imports[match.last]}\""       
      end
    end

    def get_remote url, root_url = 'http:/'
      url = URI::join(root_url, url) unless url.strip.start_with? "http://"
      puts "[GET] " + url.to_s
      res = Net::HTTP.get_response URI( url ) 
      if res.is_a?(Net::HTTPSuccess)
        yield res.body.force_encoding("UTF-8") if block_given?
      end
    end

  end
end