#Copyright (c) 2007 Aaron Smith (aaron@rubyamf.org) - MIT License

require 'adapter_settings'
require 'app/request_store'
require 'exception/rubyamf_exception'
require 'ostruct'
require 'util/string_util'
include RUBYAMF::App
include RUBYAMF::Exceptions

module RUBYAMF
module Actions

#This sets up each body for processing
class PrepareAction
  def run(amfbody)
    RequestStore.flex_messaging = false #reset to false
    if RequestStore.amf_encoding == 'amf3' #AMF3
      tmp_val = amfbody.value[0]
      if tmp_val.is_a?(OpenStruct)
        if tmp_val._explicitType == 'flex.messaging.messages.RemotingMessage' #Flex Messaging setup
          RequestStore.flex_messaging = true
  				amfbody.special_handling = 'RemotingMessage'
  				amfbody.value = tmp_val.body
  				amfbody.special_handling = 'RemotingMessage'
  				amfbody.set_meta('clientId', tmp_val.clientId)
  				amfbody.set_meta('messageId', tmp_val.messageId)
          amfbody.target_uri = tmp_val.source
          amfbody.service_method_name = tmp_val.operation
          amfbody._explicitType = 'flex.messaging.messages.RemotingMessage'
  				amfbody.set_amf3_class_file_and_uri
        elsif tmp_val._explicitType == 'flex.messaging.messages.CommandMessage' #it's a ping, don't process this body
          if tmp_val.operation == 5
            amfbody.exec = false
            amfbody.special_handling = 'Ping'
    				amfbody.set_meta('clientId', tmp_val.clientId)
    				amfbody.set_meta('messageId', tmp_val.messageId)
    			end
        else #is amf3, but set these props the same way as amf0, and not flex
          amfbody.set_amf0_class_file_and_uri
          amfbody.set_amf0_service_and_method
        end
      else #is amf3, but set these props the same way as amf0, and not flex
        amfbody.set_amf0_class_file_and_uri
        amfbody.set_amf0_service_and_method
      end
    elsif RequestStore.amf_encoding == 'amf0' #AMF0
      amfbody.set_amf0_class_file_and_uri 
      amfbody.set_amf0_service_and_method
    end    
  end    
end

#Loads the file that contains the service method you are calling
class ClassAction
	def run(amfbody)
	  if amfbody.exec == false
      return
    end
	  
	  if RequestStore.rails
	    amfbody.class_file = amfbody.class_file.snake_case #=> MyController -> my_controller
	  end
	  
		filename = RequestStore.service_path + amfbody.class_file_uri + amfbody.class_file
		$:.unshift(RequestStore.service_path) #add the service location to load path
    
    if RequestStore.reload_services
      begin
        Object.send('remove_const',amfbody.service_name)
      rescue Exception => e #do nothing, the first time running the const won't ever exist, just suppres it
      end
    end
    
	  begin
		  load(filename) #load the file
		rescue LoadError => le
		  raise RUBYAMFException.new(RUBYAMFException.LOAD_CLASS_FILE, "Error loading file - #{le.to_s}")
		rescue TypeError => te
		  if te.message.match(/superclass mismatch/) == nil
		    raise RUBYAMFException.new(RUBYAMFException.LOAD_CLASS_FILE, "There was an error loading #{filename} - #{e.to_s}")
		  end
	  rescue Exception => e
		  raise RUBYAMFException.new(RUBYAMFException.LOAD_CLASS_FILE, "There was an error loading #{filename} - #{e.to_s}")
	  ensure
		  $:.shift #clear the service path that was put into the load path array
	  end
	end
end

#Invoke a service call on the loaded class (loads the class in the class_action)
class InvokeAction
	def run(amfbody)
	  if amfbody.exec == false
	    if amfbody.special_handling == 'Ping'	      
        amfbody.results = generate_acknowledge_object(amfbody.get_meta('messageId'), amfbody.get_meta('clientId')) #generate an empty acknowledge message here, no body needed for a ping
        amfbody.success! #flag the success response
      end
      return
	  end
		@amfbody = amfbody #store amfbody in member var
		invoke
	end

	#invoke the service call
	def invoke
		begin
		  @service = Object.const_get(@amfbody.service_name).new #handle on service
		  RequestStore.available_services[@amfbody.service_name] = @service
		rescue LoadError => e
			raise RUBYAMFException.new(RUBYAMFException.LOAD_CLASS_FILE, "The file #{@amfbody.class_file_uri}#{@amfbody.class_file} was not loaded. Check to make sure it exists in: #{RequestStore.service_path}")
		rescue Exception => e
		  raise RUBYAMFException.new(RUBYAMFException.LOAD_CLASS_FILE, "There was an error loading file #{@amfbody.class_file_uri}#{@amfbody.class_file}.")
		end
    
    #authentication, simple
	  if RequestStore.auth_header != nil
	    if @service.public_methods.include?('_authenticate')
	      begin
  	      res = @service.send('_authenticate', *[RequestStore.auth_header.value.userid, RequestStore.auth_header.value.password])
          if res == false #catch false
      		  raise RUBYAMFException.new(RUBYAMFException.AUTHENTICATION_ERROR, "Authentication Failed");
          elsif res.class.to_s == 'FaultObject' #catch returned FaultObjects
      		  raise RUBYAMFException.new(res.code, res.message)
      		end
      	rescue Exception => e #catch raised FaultObjects
      	  if e.message == "exception class/object expected"
      	    raise RUBYAMFException.new(RUBYAMFException.USER_ERROR,"You cannot raise a FaultObject, return it instead.")
      	  else  
      	    raise RUBYAMFException.new(RUBYAMFException.USER_ERROR,e.message)
      	  end
      	end
    	end
	  end
    
    #before_filter
    if @service.public_methods.include?('before_filter')
	    begin
	      res = @service.send('before_filter')
  	    if res == false #catch false
  	      raise RUBYAMFException.new(RUBYAMFException.FILTER_CHAIN_HAULTED, "before_filter haulted by returning false")
  	    elsif res.class.to_s == 'FaultObject' #catch returned FaultObjects
  	      raise RUBYAMFException.new(res.code, res.message)
  	    end
    	rescue Exception => e #catch raised FaultObjects
    	  if e.message == "exception class/object expected"
    	    raise RUBYAMFException.new(RUBYAMFException.USER_ERROR,"You cannot raise a FaultObject, return it instead.")
    	  else  
    	    raise RUBYAMFException.new(RUBYAMFException.USER_ERROR,e.message)
    	  end
    	end
	  end
	  
		if @service.private_methods.include?(@amfbody.service_method_name)
			raise RUBYAMFException.new(RUBYAMFException.METHOD_ACCESS_ERROR, "The method {#{@amfbody.service_method_name}} in class {#{@amfbody.class_file_uri}#{@amfbody.class_file}} is declared as private, it must be defined as public to access it.")
		elsif !@service.public_methods.include?(@amfbody.service_method_name)
			raise RUBYAMFException.new(RUBYAMFException.METHOD_UNDEFINED_METHOD_ERROR, "The method {#{@amfbody.service_method_name}} in class {#{@amfbody.class_file_uri}#{@amfbody.class_file}} is not declared.")
		end
		
		begin
			if @amfbody.value.empty?
				@service_result = @service.send(@amfbody.service_method_name)
			else
				args = @amfbody.value
				@service_result = @service.send(@amfbody.service_method_name, *args) #* splat the argument values to pass correctly to the service method
			end
		rescue Exception => e #catch any method call errors, transform into RUBYAMFErrors so that they propogate back to flash correctly
			if e.message == "exception class/object expected"
  	    raise RUBYAMFException.new(RUBYAMFException.USER_ERROR,"You cannot raise a FaultObject, return it instead.")
  	  else  
			  raise RUBYAMFException.new(RUBYAMFException.USER_ERROR, e.to_s)
			end
		end
		
		#catch returned custom FaultObjects
		if @service_result.class.to_s == 'FaultObject'
		  raise RUBYAMFException.new(@service_result.code, @service_result.message)
		end
			  
		@amfbody.results = @service_result #set the result in this body object
		
		#amf3
    if @amfbody.special_handling == 'RemotingMessage'
      @wrapper = generate_acknowledge_object(@amfbody.get_meta('messageId'), @amfbody.get_meta('clientId'))
      @wrapper.body = @service_result
      @amfbody.results = @wrapper
		end
		
	  @amfbody.success! #set the success response uri flag (/onResult)		
	end
end

#Invoke a service call on the loaded class (loads the class in the class_action)
class RailsInvokeAction
  
  require 'util/action_controller_run_target'
  
	def run(amfbody)
	  if amfbody.exec == false
	    if amfbody.special_handling == 'Ping'	      
        amfbody.results = generate_acknowledge_object(amfbody.get_meta('messageId'), amfbody.get_meta('clientId')) #generate an empty acknowledge message here, no body needed for a ping
        amfbody.success! #flag the success response
      end
      return
	  end
		@amfbody = amfbody #store amfbody in member var
		invoke
	end
  
	#invoke the service call
	def invoke
		begin
	    @service = Object.const_get(@amfbody.service_name).new #handle on service
	    RequestStore.available_services[@amfbody.service_name] = @service
		rescue LoadError => e
			raise RUBYAMFException.new(RUBYAMFException.LOAD_CLASS_FILE, "The file #{@amfbody.class_file_uri}#{@amfbody.class_file} was not loaded. Check to make sure it exists in: #{RequestStore.service_path}")
		rescue Exception => e
		  raise RUBYAMFException.new(RUBYAMFException.LOAD_CLASS_FILE, "There was an error loading file #{@amfbody.class_file_uri}#{@amfbody.class_file}.")
		end
		
		if @service.private_methods.include?(@amfbody.service_method_name)
			raise RUBYAMFException.new(RUBYAMFException.METHOD_ACCESS_ERROR, "The method {#{@amfbody.service_method_name}} in class {#{@amfbody.class_file_uri}#{@amfbody.class_file}} is declared as private, it must be defined as public to access it.")
		elsif !@service.public_methods.include?(@amfbody.service_method_name)
			raise RUBYAMFException.new(RUBYAMFException.METHOD_UNDEFINED_METHOD_ERROR, "The method {#{@amfbody.service_method_name}} in class {#{@amfbody.class_file_uri}#{@amfbody.class_file}} is not declared.")
		end
			
		begin
		  #attribute injections
      class << @service
        attr_accessor :params
        attr_accessor :cookies
        attr_accessor :session
      end
      @service.cookies = RequestStore.rails_cookies
      @service.session = RequestStore.rails_session
      
			if @amfbody.value.empty?
        @service_result = @service.run_target_with_filters(@amfbody.service_method_name)
			else
			  if RequestStore.use_params_hash
				  @service.params = @amfbody.value
				  @service_result = @service.run_target_with_filters(@amfbody.service_method_name)
        else
			    args = @amfbody.value
			    @service_result = @service.run_target_with_filters(@amfbody.service_method_name,*args) #splat the args
        end			  
			end
  	rescue Exception => e #catch raised FaultObjects
  	  if e.message == "exception class/object expected"
  	    raise RUBYAMFException.new(RUBYAMFException.USER_ERROR,"You cannot raise a FaultObject, return it instead.")
  	  else  
  	    raise RUBYAMFException.new(RUBYAMFException.USER_ERROR,e.message)
  	  end
  	end
  			
		#handles custom faultobjects
		if @service_result.class.to_s == 'FaultObject'
		  raise RUBYAMFException.new(@service_result.code, @service_result.message)
		end
				
		@amfbody.results = @service_result #set the result in this body object
		
		#amf3
    if @amfbody.special_handling == 'RemotingMessage'
      @wrapper = generate_acknowledge_object(@amfbody.get_meta('messageId'), @amfbody.get_meta('clientId'))
      @wrapper.body = @service_result
      @amfbody.results = @wrapper
		end
	  @amfbody.success! #set the success response uri flag (/onResult)		
	end
end


#this class takes the amfobj's results (if a db result) and adapts it to a flash recordset
class ResultAdapterAction
  include Adapters #include the module that defines what adapters to test for
  
	def run(amfbody)
    new_results = '' #for some reason this has to be initialized here.. not sure why
		if amfbody.special_handling == 'RemotingMessage'
		  results = amfbody.results.body
		else
		  results = amfbody.results
		end
    
    begin
      if adapters.class.to_s == "Array"
        if adapters.empty?
          new_results = results
        else
          adapters.each do |adapter|
            require RequestStore.adapters_path + adapter[0]
            adapter = Object.const_get(adapter[1]).new
            if adapter.use_adapter?(results)
              new_results = adapter.run(results)
              break #if an adapter is used; break before the loop breaks the results on the else condition
            else
              new_results = results
            end
          end
        end
      end
    rescue Exception => e
    end
    
		if amfbody.special_handling == 'RemotingMessage'
		  amfbody.results.body = new_results
	  else
	    amfbody.results = new_results
	  end
	end
end

def generate_acknowledge_object(message_id = nil, client_id = nil)
  res = OpenStruct.new
	res._explicitType = "flex.messaging.messages.AcknowledgeMessage"
  res.messageId = rand_uuid
  if client_id == nil
    res.clientId = rand_uuid
  else
    res.clientId = client_id
  end
  res.destination = nil
  res.body = nil
  res.timeToLive = 0
  res.timestamp = (String(Time.new) + '00')
  res.headers = {}
  res.correlationId = message_id
  return res
end

#going for speed with these UUID's not neccessarily unique in space and time continue - um, word
def rand_uuid
  [8,4,4,4,12].map {|n| rand_hex_3(n)}.join('-').to_s
end

def rand_hex_3(l)
  "%0#{l}x" % rand(1 << l*4)
end
end
end
