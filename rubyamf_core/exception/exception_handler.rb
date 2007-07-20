#Copyright (c) 2007 Aaron Smith (aaron@rubyamf.org) - MIT License

require 'app/request_store'
require 'app/amf'
include RUBYAMF::App
include RUBYAMF::AMF

module RUBYAMF
module Exceptions

#This class is used to take an RUBYAMFException and translate it into something that is useful when returned back to flash.
class ExceptionHandler
	def ExceptionHandler.HandleException(e, body)
		if(RequestStore.amf_encoding == 'amf3')
      body.results = AS3Fault.new(e)
    else
      body.fail! #force the fail trigger for F8, this causes it to map to the onFault handler
      body.results = ASFault.new(e)
    end
	end
end
end
end