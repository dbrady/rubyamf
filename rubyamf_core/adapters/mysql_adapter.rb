#Copyright (c) 2007 Aaron Smith (aaron@rubyamf.org) - MIT License

require 'app/amf'
include RUBYAMF::AMF

#Adapt a Mysql::Result class into an ASRecordSet
class MysqlAdapter
	
	def use_adapter?(result)
	  begin
	    if result.class.to_s == 'Mysql::Result'
        return true
      end
    rescue Exception => e
      false
    end
	end
	
	#run the action on an AMFBody#result instance var
	def run(result)
		
		column_names = Array.new #store the column names
		fields = result.fetch_fields #get all the fields
		fields.each do |field|
			column_names << field.name #push a field into the coumn_names
		end
		
		row_count = result.num_rows #get the number of rows in the Mysql::Result
		initial_data = Array.new #payload holder
		
		result.data_seek(0) #Seek the cursor to the beginning of the data
		while row = result.fetch_row
			initial_data << row # add a row to the payload
		end
				
		asrecordset = ASRecordset.new(row_count,column_names,initial_data)
		result = asrecordset
		return result
	end
end