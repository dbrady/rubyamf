#Copyright (c) 2007 Aaron Smith (aaron@rubyamf.org) - MIT License

module MarshalStartup
  
  #redeclare these default options, as if there is an error reading the startup options we use default ones
  DEFAULT_OPTIONS = {}
  DEFAULT_OPTIONS[:windows] = false
  DEFAULT_OPTIONS[:working_dir] = Dir::pwd
  DEFAULT_OPTIONS[:document_root] = Dir::pwd + '/public/'
  DEFAULT_OPTIONS[:services_path] = 'services/' #default to nil
  DEFAULT_OPTIONS[:start_server] = true #start the server, if -h is supplied the server isn't started
  DEFAULT_OPTIONS[:server_type] = 'webrick' #default to webrick
  DEFAULT_OPTIONS[:ip] = '127.0.0.1'
  DEFAULT_OPTIONS[:port] = 8024 #default port
  DEFAULT_OPTIONS[:gateway] = '/gateway.rb' #default mount point for webrick
  DEFAULT_OPTIONS[:lighttpd_config] = 'aspawn' #default lighttpd config type
  DEFAULT_OPTIONS[:daemon] = false #don't daemonize webrick
  DEFAULT_OPTIONS[:log_file] = 'rubyamf_core/logs/rubyamf.log' #default logging to file
  DEFAULT_OPTIONS[:log_level] = 'none' #default log level
  DEFAULT_OPTIONS[:processes] = 3 #this sets the number of processors for Mongrel and LightTPD
  DEFAULT_OPTIONS[:net_debug] = false #no netDebug tracing by default
  DEFAULT_OPTIONS[:backtrace] = false #no backtraces by default
  DEFAULT_OPTIONS[:reload] = false #reloadable services
  
  def MarshalStartup.save_startup_options(options)
    begin
    	data = Marshal.dump(options)
    	File.open("server/startup/options", 'w', 0777) do |f|
    		f.puts data
    	end
    rescue Exception => e
      puts e.to_s
      puts e.backtrace
    end
  end
  
  def MarshalStartup.restore_startup_options
    #try to load marshaled startup options. if not succeeded revert to defaults
    data = ''
    begin
      File.open(RUBYAMF_ROOT + "/server/startup/options", 'r') do |f|
      	while line = f.gets
      		data << line
      	end
      end
    rescue Exception => e
      raise e
    end
    
    begin #catch when a marshl.load doesn't succeed, if doesn't succeed, just make a new session hash
    	opts = Marshal.load(data)
    rescue Exception => e
      opts = DEFAULT_OPTIONS
      raise e
    end
    
    opts
  end
  
  #get the default options
  def MarshalStartup.get_defaults
    DEFAULT_OPTIONS
  end
end