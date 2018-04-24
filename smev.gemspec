$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "smev/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "smev"
  s.version     = Smev::VERSION
  s.authors     = ["S. Fedosov"]
  s.email       = ["wolferingys@gmail.com"]
  s.homepage    = "https://github.com/Wolfer/smev"
  s.summary     = "Easy work with Smev."
  s.description = "Easy work with Smev messages in Ruby."

  s.files = Dir["{lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_development_dependency "rspec"
#  s.add_dependency "soap4r"
  s.add_dependency "nori"
  s.add_dependency "macaddr", '= 1.6.1'
  s.add_dependency "uuid"
  s.add_dependency "nokogiri", '~> 1.8'
  s.add_dependency "rubyzip", '~> 1.0'
  s.add_dependency "mime-types"
  s.add_dependency "httpi"
end
