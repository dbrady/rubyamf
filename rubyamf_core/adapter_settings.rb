#Copyright (c) 2007 Aaron Smith (aaron@rubyamf.org) - MIT License

module Adapters
def adapters

@adapters = []

#~ADAPTERS
#~Adapters are used to take a service method call result, and alter it in someway before sending it back to Flash,
#~most commonly used for Database results.

#~Adapters live in rubyamf_core/adapters/. in the array below, mysql_adapter is the mysql_adapter.rb file, and MysqlAdapter is the class
#~defined in that file. Each adapter class must have a "user_adapter?" method defined that is used to determine if that adapter should 
#~be used with the results passed to it. each Adapter file must also have a "run" method that is executed when the "use_adapter?" returns true
#~you can look at either mysql_adapter or active_record_adapter

@adapters << ['active_record_adapter', 'ActiveRecordAdapter']
#@adapters << ['firebird_fireruby_adapter', 'FirebirdFirerubyAdapter']
#@adapters << ['hypersonic_adapter','HypersonicAdapter']
#@adapters << ['lafcadio_adapter','LafcadioAdapter']
@adapters << ['mysql_adapter', 'MysqlAdapter']
#@adapters << ['object_graph_adapter','ObjectGraphAdapter']
#@adapters << ['oracle_oci8_adapter', 'OracleOCI8Adapter']
#@adapters << ['postgres_adapter', 'PostgresAdapter']
#@adapters << ['ruby_dbi_adapter', 'RubyDBIAdapter']
#@adapters << ['sequel_adapter','SequelAdapter']
#@adapters << ['sqlite_adapter','SqliteAdapter']
return @adapters
end
end