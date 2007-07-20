require 'rubygems'
require 'action_controller'
require RUBYAMF_CORE + 'exception/rubyamf_exception'
include RUBYAMF::Exceptions

#basic format class to handle the amf format
class AmfFormat
  def amf
    if block_given?
      yield
    end
  end
  
  def method_missing(meth)
    return false
  end
end

#this defines a run_target_with_filters method on ActionController::Base,
#it will run before filters, the target method, then the after methods in order
class ActionController::Base
  
  attr_accessor :is_amf
  attr_accessor :allow_after_filters
  attr_accessor :amf_content
  attr_accessor :used_render_amf
  
  alias_method :render_amf, :render
  
  #redefine the render method for amf, sweet
  def render(hash)
    self.used_render_amf = true
    self.amf_content = hash[:amf]
  end
  
  #redefine respond_to
  def respond_to
    if block_given?
      f = AmfFormat.new
      yield(f)
    end
  end

  #set up credentials for remoting
  def amf_credentials
    if RequestStore.rails_authentication == nil
      return {}
    end
    return RequestStore.rails_authentication
  end
  
  #run a target method with filters  
  def run_target_with_filters(method, args = [])
    self.is_amf = true
    self.allow_after_filters = false
    
    afters = []
    befores = []
    
    #populate the before and after arrays
    self.filter_chain.each do |fl|
      if(fl.inspect.to_s.match(/BeforeFilter/))
        befores << fl
      elsif(fl.class.to_s.match(/AfterFilter/))
        afters.unshift(fl)
      end
    end
    
    @executed_filters = {}
    befores.each do |fl|
      begin
        if @executed_filters[fl.filter] || @executed_filters[fl.filter.inspect.to_s.split('/').last.to_s]
          next
        end
        if fl.inspect.to_s.match(/Proc/) != nil #proc filter
          r = fl.filter.call(self)
          if r == false #catch false
            line = fl.filter.inspect.to_s.split('/').last.split(':').last.sub('>','')
            raise RUBYAMFException.new(RUBYAMFException.FILTER_CHAIN_HAULTED, "The Rails proc filter on line {#{line}} haulted")
          elsif r.class.to_s == 'FaultObject' #catch return FaultObject's
            raise RUBYAMFException.new(r.faultCode, r.faultString)
          end
          @executed_filters[fl.filter.inspect.split('/').last.to_s] = true
        else #method filter
          if args.empty?
            r = self.send(fl.filter.to_s)
          else
            r = self.send(fl.filter.to_s, *args) #splat args out
          end
          
          if r == false #catch false
            raise RUBYAMFException.new(RUBYAMFException.FILTER_CHAIN_HAULTED, "The Rails method filter {#{fl.filter.to_s}} haulted")            
          elsif r.class.to_s == 'FaultObject' #catch returned FaultObjects
            raise RUBYAMFException.new(r.faultCode, r.faultString)
          end
          @executed_filters[fl.filter] = true
        end
        #elsif(fl.inspect.to_s.match(/ProcWithCallFilter/))
        #  fl.filter.call(controller, ?action?)
      rescue Exception => e #catch exceptions
    	  if e.message == "exception class/object expected" #if raised a RubyAMF FaultObject
    	    raise RUBYAMFException.new(RUBYAMFException.USER_ERROR,"You cannot raise a FaultObject, return it instead.")
    	  else  
    	    raise RUBYAMFException.new(RUBYAMFException.USER_ERROR,e.message)
    	  end
      rescue LocalJumpError => e #incorrect superclass error supression
        next
      end
    end
    
    begin
      res = self.send(method) #Call target Method
      if !self.allow_after_filters
        if self.used_render_amf #flag if used respond_to, then content will be in self.amf_content
          return self.amf_content
        else
          return res #return prematurely
        end
      end
    rescue Exception => e
      raise RUBYAMFException.new(RUBYAMFException.USER_ERROR, e.message)
    end
    
    #Call afters
    afters.each do |fl|
      begin
        if @executed_filters[fl.filter] || @executed_filters[fl.filter.inspect.to_s.split('/').last.to_s]
          next
        end
        if(fl.inspect.to_s.match(/Proc/) != nil)
          r = fl.filter.call(self)
          if r == false #catch false
            line = fl.filter.inspect.to_s.split('/').last.split(':').last.sub('>','')
            raise RUBYAMFException.new(RUBYAMFException.FILTER_CHAIN_HAULTED, "The Rails proc filter on line {#{line}} haulted")
          elsif r.class.to_s == 'FaultObject' #catch return FaultObject's
            raise RUBYAMFException.new(r.faultCode, r.faultString)
          end
          @executed_filters[fl.filter.inspect.split('/').last.to_s] = true
        else
          #call method
          if args.empty?
            r = self.send(fl.filter.to_s)
          else
            r = self.send(fl.filter.to_s,args)
          end
          
          if r == false #catch false
            raise RUBYAMFException.new(RUBYAMFException.FILTER_CHAIN_HAULTED, "The Rails method filter {#{fl.filter.to_s}} haulted")            
          elsif r.class.to_s == 'FaultObject' #catch returned FaultObjects
            raise RUBYAMFException.new(r.faultCode, r.faultString)
          end
          @executed_filters[fl.filter] = true
        end
        #elsif(fl.inspect.to_s.match(/ProcWithCallFilter/))
        #  fl.filter.call(controller, ?action?)
      rescue Exception => e #catch exceptions
    	  if e.message == "exception class/object expected" #if raised a RubyAMF FaultObject
    	    raise RUBYAMFException.new(RUBYAMFException.USER_ERROR,"You cannot raise a FaultObject, return it instead.")
    	  else  
    	    raise RUBYAMFException.new(RUBYAMFException.USER_ERROR,e.message)
    	  end
      rescue LocalJumpError => e #incorrect superclass error supression
        next
      end
    end
    
    if self.used_render_amf
      return self.amf_content
    else
      return r #return the last value of r
    end
  end
end