#!/usr/bin/env ruby -w

#Copyright (c) 2007 Aaron Smith (aaron@rubyamf.org) - MIT License

#this will catch errors in this scope only. Any errors through the AMF process will be caught in BatchFilter
#and transformed into a valid AMF fault object to be returned to flash
begin
  RUBYAMF_CORE = File.expand_path(File.dirname(__FILE__))  + '/'
  RUBYAMF_ROOT = File.expand_path( File.dirname(__FILE__) ) + "/../"
  RUBYAMF_PUBLIC = File.expand_path( File.dirname(__FILE__) ) + '/../public/'
  RUBYAMF_HELPERS = RUBYAMF_ROOT + '/services/service_helpers/'
  RUBYAMF_VO = RUBYAMF_ROOT + 'service_vo/'
  $:.unshift(RUBYAMF_CORE)
  
  #now require the support classes to handle the amf request
  require 'cgi'
  require 'app/gateway'
  require 'app/request_store'
  require 'util/log'
  include RUBYAMF::App
  include RUBYAMF::Util
  
  #log file must be set before any logging takes place, as trying to changing the logger to use a log file
  #after it has already been initialized fails.
  Log.SetLogFile(RUBYAMF_CORE + 'logs/rubyamf.log')
  @log = Log.instance #init the logger, set level below
  
  #now get the saved startup options (default if exception is raised)
  begin
    require RUBYAMF_ROOT + 'server/support/marshal_startup'
    OPTIONS = MarshalStartup.restore_startup_options
  rescue Exception => e
    OPTIONS = MarshalStartup.get_defaults
  end
  
  #services have to be set here otherwise exceptions are thrown, not sure why
  RUBYAMF_SERVICES = RUBYAMF_ROOT + '/services/'
  
  #request store is just for this request.
  RequestStore.query_params = cgi.params()
  RequestStore.reload_services = false
  
  #create a new rubyamf gateway for processing
  gateway = Gateway.new

  #set services path on gateway
  gateway.services_path = RUBYAMF_SERVICES
  gateway.config_path = RUBYAMF_SERVICES + '/config/'

  #default log level (debug, info, warn, error, fatal)
  gateway.log_level = 'fatal'
  
  #see an exceptions backtrace in the fault object / netconnection debugger and the logger.
  gateway.backtrace_on_error = false
  
  #turn on or off NetDebug functionality
  gateway.allow_net_debug = false
  
	#if your using Flash 9 with Flash Remoting the format needs to be 'fl9'
	#if your useing Flash 8 with Flash Remogin the format needs to be 'fl8'
	#Flex FDS RemoteObject is handled nativly. No need to adjust the format for that.
	gateway.recordset_format = 'fl8' #OR 'fl9'
	#Note: You can use netConnection.addHeader to change this from Flash instead.
	#service.addHeader('recordset_format',false,'fl9');
	#service.addHeader('recordset_format',false,'fl8')
  #Read more about why this has to be specifically set at wiki.rubyamf.org/wiki/show/RecordSetFormat
  
  if(cgi.content_type == nil || !cgi.content_type.include?('x-amf'))
	  amf_response = "Your RubyAMF Flash Remoting gateway is alive and well. See 
	  <a href='http://wiki.rubyamf.org'>wiki.rubyamf.org</a> for more information."
    cgi.out("text/html"){amf_response}
  else
    #simple benchmarking--
    #require 'benchmark'
    #amf_response = ''
    #File.open( 'benchmark.log','a') do |f|
    #  f.puts Benchmark.measure{ 15.times do amf_response = gateway.service(cgi.params.keys.first) end }  #keep the loop somewhat short as the player times out
    #end
    #send the content
    amf_response = gateway.service(cgi.params.keys.first)
    cgi.out("application/x-amf"){amf_response}
  end
rescue Exception => e
  STDOUT.puts e.to_s
  STDOUT.puts e.backtrace
end