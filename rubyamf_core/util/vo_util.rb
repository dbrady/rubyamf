#utility method to get a vo object mapping from the vo_mappings module
require 'app/configuration'
require 'app/request_store'
require 'exception/rubyamf_exception'
include RUBYAMF::Configuration

class VoUtil
  def self.get_vo_for_incoming(os,classname)
    begin      
      #obj will always be an open struct, it's the classname that tells me what to map to
      mappings = ValueObjects.get_vo_mappings
            
      #if no mappings return the OpenStruct
      if mappings.empty? || mappings.nil?
        return os
      end
      
      vo = nil
      vomap = nil
      active_rec = false
      mappings.each do |map|
        if map[:incoming] == classname
          vomap = map #store vomap
          if map[:type] != nil && map[:type] == 'active_record'
            vo = self.get_active_record_from_open_struct(os)
            active_rec = true
            break
          else
            filepath = map[:map_to].split('.').join('/').to_s + '.rb' #set up filepath from the map_to symbol
            require RUBYAMF_VO + '/' + filepath #require the file
            vo = Object.const_get(classname.split('.').last).new #this returns an instance of the VO
            break
          end
        end
      end
      
      #if this was an active record VO, return it prematurely
      if active_rec
        return vo
      end
      
      #vo wasn't created, just return the open struct
      if vo == nil
        return os
      end
      
      #assign values to new VO object
      members = os.get_members
      members.each do |member|
        eval("vo.#{member} = os.#{member}")
      end
      
      #Assing RubyAMF tracking vars
      vo._explicitType = vomap[:map_to] #assign the VO it's 'mapped_to' classname
      vo.rmembers = members
      vo
    rescue LoadError => le
      raise RUBYAMFException.new(RUBYAMFException.VO_ERROR, "Tho VO definition #{classname} could not be found. #{le.message}")
    end
  end
  
  def self.get_vo_for_outgoing(obj)
    begin
      if obj._explicitType != nil
        classname = obj._explicitType
      else
        classname = obj.class.to_s
      end

      vo = nil
      vomap = nil
      mappings = ValueObjects.get_vo_mappings
      mappings.each do |map|
        if map[:map_to] == classname
          vomap = map
          obj._explicitType = map[:outgoing]
          break;
        end
      end
      return obj
    rescue Exception => e
      raise RUBYAMFException.new(RUBYAMFException.VO_ERROR, e.message)
    end
  end
  
  #get a mapping from an active record instance, used in active record adapter
  def self.get_vo_definition_from_active_record(classname)
    mappings = ValueObjects.get_vo_mappings
    mappings.each do |map|
      if map[:map_to] == classname
        return map
      end
    end
    nil
  end
  
  #make an init hash for AR from an open struct
  def self.make_hash_for_active_record_from_open_struct(os)
    hash = {}
    members = os.get_members
    members.each do |key|
      if key == '_explicitType' || key == 'rmembers'
        next
      end
      val = os.send(:"#{key}")
      hash[key] = val
    end
    hash
  end
  
  #get an active record from an incoming VO openStruct
  def self.get_active_record_from_open_struct(os)
    if os._explicitType == nil
      return nil
    end

    if os._explicitType.include?('.')
      classname = os._explicitType.split('.').last
    else
      classname = os._explicitType
    end

    hash = self.make_hash_for_active_record_from_open_struct(os)
    ActiveRecord::Base.update_nil_associations(Object.const_get(classname),hash) #update the hash so nil assotiations don't mess up AR
    ActiveRecord::Base.update_nans(hash)
    ar = Object.const_get(classname).new(hash)
    return ar
  end
end