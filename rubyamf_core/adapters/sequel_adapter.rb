#Copyright (c) 2007 Aaron Smith (aaron@rubyamf.org) - MIT License

require 'app/amf'
include RUBYAMF::AMF

#Sequel ORM Adapter
class SequelAdapter
  
  def use_adapter?(result)
    begin
      if result.class.to_s.match(/Sequel::[a-zA-Z0-9]*::Dataset/)
        return true
      end
      false
    rescue Exception => e
      false
    end
  end
  
  #run results through sequel adapter
  def run(results)
    columns_names = rows.first.inject([]) {|m, kv| m << kv[0]; m}
    row_count = rows.size
    initial_data = results.all.map {|r| columns.map {|c| r[c]}}
    asrecordset = ASRecordset.new(row_count,column_names,initial_data)
  	result = asrecordset
  	return result
  end
end