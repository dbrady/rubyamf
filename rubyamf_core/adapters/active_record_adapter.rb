require 'ostruct'

class ActiveRecordAdapter
  
  #should we use this adapter for the result type
  def use_adapter?(results)
    if(use_multiple?(results) || use_single?(results))
      return true
    end
    false
  end
  
  #run the results through this adapter
  def run(results)
    if(use_multiple?(results))
      results = run_multiple(results)
    else
      results = run_single(results)
    end
    return results
  end

  #is the result an array of active records
  def use_multiple?(results)
    if(results.class.to_s == 'Array' && results[0].class.superclass.to_s == 'ActiveRecord::Base')
      return true
    end
    false
  end

  #is this result a single active record?
  def use_single?(results)
    if(results.class.superclass.to_s == 'ActiveRecord::Base')
      return true
    end
    false
  end
  
  #run the data extaction process on an array of AR results
  def run_multiple(um)
    initial_data = []
    column_names = um[0].get_column_names
    num_rows = um.length

    c = 0
    0.upto(num_rows - 1) do
      o = OpenStruct.new
      class << o
        attr_accessor :id
      end
      
      #turn the outgoing object into a VO if neccessary
      map = VoUtil.get_vo_definition_from_active_record(um[0].class.to_s)
      if map != nil
        o._explicitType = map[:outgoing]
      end
      
      #first write the primary "attributes" on this AR object
      column_names.each_with_index do |v,k|
        k = column_names[k]
        val = um[c].send(:"#{k}")
        eval("o.#{k}=val")
      end
      
      associations = um[0].get_associates
      if(!associations.empty?)
        #now write the associated models with this AR
        associations.each do |associate|
          na = associate[1, associate.length]
          ar = um[c].send(:"#{na}")
          if !ar.empty? && !ar.nil?
            if(use_single?(ar))
              initial_data_2 = run_single(ar)   #recurse into single AR method for same data structure
            else
              initial_data_2 = run_multiple(ar) #recurse into multiple AR method for same data structure
            end
            eval("o.#{na}=initial_data_2")
          end
        end
      end
      c += 1
      initial_data << o
    end
    initial_data
  end

  #run the data extraction process on a single AR result
  def run_single(us)
    initial_data = []
    column_names = us.get_column_names
    num_rows = 1
    
    c = 0
    0.upto(num_rows - 1) do
      o = OpenStruct.new
      class << o
        attr_accessor :id
      end

      #turn the outgoing object into a VO if neccessary
      map = VoUtil.get_vo_definition_from_active_record(us.class.to_s)
      if map != nil
        o._explicitType = map[:outgoing]
      end
      
      #first write the primary "attributes" on this AR object
      column_names.each_with_index do |v,k|
        k = column_names[k]
        val = us.send(:"#{k}")
        eval("o.#{k}=val")
      end
      
      associations = us.get_associates
      if(!associations.empty?)
        #now write the associated models with this AR
        associations.each do |associate|
          na = associate[1, associate.length]
          ar = us.send(:"#{na}")
          if !ar.empty? && !ar.nil?
            if(use_single?(ar))
              initial_data_2 = run_single(ar)   #recurse into single AR method for same data structure
            else
              initial_data_2 = run_multiple(ar) #recurse into multiple AR method for same data structure
            end
            eval("o.#{na}=initial_data_2")
          end
        end
      end
      if us.single?
        initial_data = o
      else
        initial_data << o
      end
      c += 1
    end
    initial_data
  end
  
end


=begin
TESTING = true
require 'rubygems'
require 'active_record'
require '../../services/org/universalremoting/browser/support/ar_models/user'
require '../../services/org/universalremoting/browser/support/ar_models/address'
require '../util/active_record'

ar = ActiveRecordAdapter.new

ActiveRecord::Base.establish_connection(:adapter => 'mysql', :host => 'localhost', :password => '', :username => 'root', :database => 'ar_rubyamf_testings')

### multiple results, including some other associations
mult = User.find(:all, :include => :addresses)

### single result
sing = User.find(402, :include => :addresses)

final = ar.run_multiple(mult)
puts "MULTIPLE -> RESULTS"
puts '--------------'
puts final.inspect
puts '--------------'
puts final[0].inspect

puts "\n\n"

finals = ar.run_single(sing)
puts "SINGLE -> RESULT"
puts '--------------'
puts finals.inspect
puts '--------------'
puts finals[0].inspect
=end