#Copyright (c) 2007 Aaron Smith (aaron@rubyamf.org) - MIT License

#core directories are set here
RUBYAMF_ROOT = File.expand_path(Dir::pwd) + '/'
RUBYAMF_CORE = File.expand_path(Dir::pwd) + '/rubyamf_core/'
RUBYAMF_PUBLIC = File.expand_path(Dir::pwd) + '/public/'
RUBYAMF_SERVICES = RUBYAMF_ROOT + OPTIONS[:services_path] #else use the root + whatever they declared.
RUBYAMF_HELPERS = RUBYAMF_SERVICES + 'service_helpers/'
RUBYAMF_VO = RUBYAMF_SERVICES + 'service_vos/'

# add rubyamf_core first search path
$:.unshift(RUBYAMF_CORE)

require 'rubygems'
begin
  require 'mongrel'
rescue Exception => e
  STDOUT.puts "You must have mongrel installed. 'sudo gem install mongrel --include-dependencies"
  exit(0)
end
require 'optparse'
require 'app/gateway'
require 'app/request_store'
require 'util/log'
include RUBYAMF::App
include RUBYAMF::Util

module RUBYAMF

class MongrelServlet < Mongrel::HttpHandler
        
    def process(request, response)
      response.start(200) do |head,out|
        
        #this only catches errors in this scope, all other errors in the RubyAMF process are caught
    	  #in BatchFilter, then transformed into an AMF acceptable Fault Object to be returned to flash
    	  begin 
          
      	  #this has to be set as the very first thing, as trying to change the logger to use a log file after it's been initialized fails
      	  Log.SetLogFile(OPTIONS[:log_file])
      	  @log = Log.instance #init the logger, set level below
          
      	  #change the working directory, as WEBrick changes it to '/' when it is started
      	  Dir.chdir(RUBYAMF_ROOT)
          
      		RequestStore.query_params = parse_query_string(request.params['QUERY_STRING']) if request.params['QUERY_STRING'] != nil
          RequestStore.reload_services = OPTIONS[:reload]
          
      		#raw post comes in as request.body
       		raw_post = request.body.read(request.body.length)
          
      		#create a new rubyamf gateway for processing
      		gateway = Gateway.new
          
      		#set the services path relative to this gateway.servlet file
      		gateway.services_path = RUBYAMF_SERVICES
      		gateway.config_path = RUBYAMF_SERVICES + '/config/'
      		
      		#the value object mapping location
    		  gateway.set_vo_path = RUBYAMF_SERVICES + 'vo'
          
      		#default log level (debug, info, warn, error, fatal, none)
      		gateway.log_level = OPTIONS[:log_level].to_s
          
      		#see an exceptions backtrace in the fault object / netconnection debugger and the logger. 
      		#Servers must be restarted if this state is changed
      		gateway.backtrace_on_error = OPTIONS[:backtrace]
          
      		#turn on or off NetDebug functionality
      		#use NetDebug.Trace(msg) in a service method.
      		gateway.allow_net_debug = OPTIONS[:net_debug]
          
    			#if your using Flash 9 with Flash Remoting the format needs to be 'fl9'
    			#if your useing Flash 8 with Flash Remogin the format needs to be 'fl8'
    			#Flex FDS RemoteObject is handled nativly. No need to adjust the format for that.
    			gateway.recordset_format = 'fl8' #OR 'fl9'
    			#Note: You can use netConnection.addHeader to change this from Flash instead.
    			#service.addHeader('recordset_format',false,'fl9');
    			#service.addHeader('recordset_format',false,'fl8')
          #Read more about why this has to be specifically set at wiki.rubyamf.org/wiki/show/RecordSetFormat
          
    			#Compress the amf output for smaller data transfer over the wire
    			if(request.params.to_s.match(/gzip,[\s]{0,1}deflate/))
    			  gateway.gzip_outgoing = false #leave false, this doesn't completely work yet
    			end
          		
      		if request.params['CONTENT_TYPE'].to_s.match(/x-amf/) == nil
      		  amf_response = "Your RubyAMF Flash Remoting gateway is alive and well. See 
      		  <a href='http://wiki.rubyamf.org'>wiki.rubyamf.org</a> for more information."
      		  head['Content-Type'] = 'text/html'
      		else
      		  #simple benchmarking--
      		  #require 'benchmark'
      		  #amf_response = ''
      		  #Benchmark.bmbm do |b|
      		  #  b.report("THE PROCESS:") {
      		  #    10.times do
      		  #      amf_response = gateway.service(raw_post)
      		  #    end
      		  #  }
      		  #end
            
      		  #send the raw data throught the rubyamf gateway
    		    amf_response = gateway.service(raw_post)
      		  head["Content-Type"] = "application/x-amf"
      		end
          out.write(amf_response)
          
    	  rescue Exception => e #only errors in this scope will ever be rescued here, see BatchFiler
          STDOUT.puts e.to_s
    	    STDOUT.puts e.backtrace
    	  end
      end
    end
  end
end
