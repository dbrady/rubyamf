#Copyright (c) 2007 Aaron Smith (aaron@rubyamf.org) - MIT License

module RUBYAMF
module App

#store information on a per request basis
class RequestStore
	
	@actions
	@filters
	@client
	@service_path
	@gateway_path
	@actions_path
	@filters_path
	@adapters_path
	@logs_path
	@dbresult_adapters = []
	@use_backtraces
	@query_params = {}
	@net_debug
	@amf_encoding
	@recover_bad_xml_with_soup
  @use_sessions
  @vo_path
  @flex_messaging = false
  @recordset_format
  @gzip = false
  @use_params_hash
  @rails = false
  @rails_authentication
  @available_services = {}
  @auth_header = nil
  @rails_cookies
  @rails_session
  @reload_services = false

	class << self
	  attr_accessor :actions
	  attr_accessor :filters
	  attr_accessor :client #0 flash player , #1 flash comm
	  attr_accessor :service_path
	  attr_accessor :gateway_path
	  attr_accessor :actions_path
	  attr_accessor :filters_path
	  attr_accessor :adapters_path
	  attr_accessor :logs_path
	  attr_accessor :dbresult_adapters
	  attr_accessor :use_backtraces
	  attr_accessor :query_params
	  attr_accessor :net_debug
	  attr_accessor :amf_encoding
	  attr_accessor :recover_bad_xml_with_soup
	  attr_accessor :use_sessions
	  attr_accessor :vo_path
	  attr_accessor :flex_messaging
	  attr_accessor :recordset_format
	  attr_accessor :gzip
	  attr_accessor :use_params_hash
	  attr_accessor :rails
	  attr_accessor :rails_authentication
	  attr_accessor :available_services
	  attr_accessor :auth_header
	  attr_accessor :rails_cookies
	  attr_accessor :rails_session
	  attr_accessor :reload_services
	end

end
end
end