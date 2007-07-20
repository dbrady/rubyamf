require 'rubygems'
require 'mysql'
require 'ostruct'
require RUBYAMF_HELPERS + 'fault_object'
class TestObject
  
  def _authenticate(user,pass)
    puts "AUTHENTICATE"
    @auth = true
  end
  
  def before_filter
    puts "BEFORE FILTER"
    if !@auth then return FaultObject.new(1,'Authentication Failed') end
  end
    
  def tObject(obj)
    a = OpenStruct.new
    a.name = 'ffffffaron'
    a.last = 'one'
    return a
    return obj
  end
  
  def getMysqlResult
	  @con = Mysql.connect("localhost","root","")
		@con.select_db("rubyamf")
    return @con.query("SELECT * FROM datas")
  end
end