class SmevException < StandardError
end
class UnexpectedElement < SmevException
	attr_accessor :element

	def initialize msg, el = nil
		super msg
		self.element = el
	end
end
