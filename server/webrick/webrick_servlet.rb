#!/usr/bin/env ruby

#Copyright (c) 2007 Aaron Smith (aaron@rubyamf.org) - MIT License

#core directories are set here
RUBYAMF_ROOT = File.expand_path(Dir::pwd) + '/'
RUBYAMF_CORE = File.expand_path(Dir::pwd) + '/rubyamf_core/'
RUBYAMF_PUBLIC = File.expand_path(Dir::pwd) + '/public/'
RUBYAMF_SERVICES = RUBYAMF_ROOT + OPTIONS[:services_path] #else use the root + whatever they declared.
RUBYAMF_HELPERS = RUBYAMF_SERVICES + 'service_helpers/'
RUBYAMF_VO = RUBYAMF_SERVICES

#add rubyamf_core as first search path
$:.unshift(RUBYAMF_CORE)

require 'optparse'
require 'webrick'
require 'app/gateway'
require 'app/request_store'
require 'util/log'
include RUBYAMF::App
include RUBYAMF::Util

module RUBYAMF

class WEBrickServlet < WEBrick::HTTPServlet::AbstractServlet
	  
	#get requests
	def do_GET(request, response)
		service(request, response)
	end
	
	#post requests
	def do_POST(request, response)
	 	service(request, response)
	end
	
	#All requests circulate through this method. Here you can set configuration details on the rubyamf gateway.
	def service(request, response)
        
	  #this only catches errors in this scope, all other errors in the rubyamf process are caught 
	  #in BatchFilter, then transformed into an AMF acceptable Fault Object to be returned to flash
	  begin 
  	  
  	  #this has to be set as the very first thing, as trying to change the logger to use a log file after it's been initialized fails
  	  Log.SetLogFile(OPTIONS[:log_file])
  	  @log = Log.instance #init the logger, set level below
  	  
  	  #change the working directory, as WEBrick changes it to '/' when it is started
  	  Dir.chdir(RUBYAMF_ROOT)
  	  
  		RequestStore.query_params = parse_query_string(request.query_string) if request.query_string != nil
		  RequestStore.reload_services = OPTIONS[:reload]
		  
  		#raw post comes in as request.body
   		raw_post = request.body
		
  		#create a new rubyamf gateway for processing
  		gateway = Gateway.new
		  
  		#set pathing options for the gateway
  		gateway.services_path = RUBYAMF_SERVICES
  		gateway.config_path = RUBYAMF_SERVICES + '/config/'
		  
  		#default log level (debug, info, warn, error, fatal, none)
  		gateway.log_level = OPTIONS[:log_level]
		  
  		#see an exceptions backtrace in the fault object / netconnection debugger and the logger. 
  		#Servers must be restarted if this state is changed
  		gateway.backtrace_on_error = OPTIONS[:backtrace]
		  
  		#turn on or off NetDebug functionality
  		#use NetDebug.Trace(msg) in a service method. #Flash 8 only
  		gateway.allow_net_debug = OPTIONS[:net_debug]
			
			#if your using Flash 9 with Flash Remoting the format needs to be 'fl9'
			#if your useing Flash 8 with Flash Remoting the format needs to be 'fl8'
			#Flex FDS RemoteObject is handled nativly. No need to adjust the format for that.
			gateway.recordset_format = 'fl8' #OR 'fl9'
			#Note: You can use netConnection.addHeader to change this from Flash instead.
			#service.addHeader('recordset_format',false,'fl9');
			#service.addHeader('recordset_format',false,'fl8');
      #Read more about why this has to be specifically set at wiki.rubyamf.org/wiki/show/RecordSetFormat
			
			#Compress the amf output for smaller data transfer over the wire
			if(request.raw_header.to_s.match(/gzip,[\s]{0,1}deflate/))
			  gateway.gzip_outgoing = false #leave false, this doesn't completely work yet.
			end
			
  	  #if not flash user agent, send some html content
  		if request.raw_header.to_s.match(/x-amf/) == nil
  		  amf_response = "Your Flash remoting gateway is alive and well. See 
  		  <a href='http://www.rubyamf.org'>rubyamf.org</a> for more information."
  		  response['Content-Type'] = 'text/html'
  		else
  		  
  		  #simple benchmarking--
  		  #require 'benchmark'
  		  #amf_response = ''
  		  #Benchmark.bmbm do |b|
  		  #  b.report("THE PROCESS:") {
  		  #    15.times do
  		  #      amf_response = gateway.service(raw_post)
  		  #    end
  		  #  }
  		  #end
        
  		  #send the raw data throught the rubyamf gateway and create the response
		    amf_response = gateway.service(raw_post)
  		  response['Content-Type'] = "application/x-amf"
  		end
  		response.body = amf_response
	  rescue Exception => e #only errors in this scope will ever be rescued here, see BatchFiler
      STDOUT.puts e.to_s
	    STDOUT.puts e.backtrace
	  end
	end
	
	#support method to parse out the query string form the request
	def parse_query_string(query_string)
	  params = {}
	  t = query_string.split('&')
	  t.each_with_index do |v,i|
	    thisparam = t[i].split('=')
	    params[thisparam[0]] = thisparam[1]
	  end
	  params
	end
end
end