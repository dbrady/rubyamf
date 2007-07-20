#Copyright (c) 2007 Aaron Smith (aaron@rubyamf.org) - MIT License

#optparser kicks off the server processes

require 'optparse'
require 'server/support/marshal_startup'

is_windows = false
if(PLATFORM.include?('mswin'))
  is_windows = true
end

#default options
OPTIONS = MarshalStartup.get_defaults

opts = OptionParser.new do |opts|
  #what server
  opts.on("-s", "--server=webrick", "Which server to start. (webrick|lighttpd|mongrel), default is webrick") do |s|
    if(s != 'webrick' && s != 'lighttpd' && s != 'mongrel')
      STDOUT.puts "Available server options are webrick and lighttpd"
      exit(0)
    end
    OPTIONS[:server_type] = s if s != nil
  end
  
  #sessions
  #opts.on("-r", "--sessions","Turn on sessions (AMF0 only)") do |r|
  #  OPTIONS[:sessions] = true
  #end
  
  #IP
  opts.on("-i","--ip=127.0.0.1", "Change the binding IP address") do |i|
    OPTIONS[:ip] = i if i != nil
  end
  
  #PORT
  opts.on("-p", "--port=PORT","Change the default port") do |p|
    OPTIONS[:port] = p if p != nil
  end
  
  opts.on("-t", "--processes=30","change the amount of processes used for Mongrel or LightTPD") do |t|
    OPTIONS[:processes] = t if t != nil
  end
  
  #gateway mount point for webrick
  opts.on("-g", "--gateway=/gateway.rb", "Change where the webrick|mongrel gateway is mounted to. (EX: /rubyamf.rb) default is /gateway.rb") do |g|
    if(OPTIONS[:server_type] == 'webrick' || OPTIONS[:server_type] == 'mongrel')
      if(g.include?('/'))
        OPTIONS[:gateway] = g if g != nil
      else
        OPTIONS[:gateway] = "/#{g}" if g != nil
      end
    else
      STDOUT.puts "You can't change the gateway with #{OPTIONS[:server_type]}."
    end
  end
  
  #services path (from RUBYAMF_PUBLIC)
  opts.on("-w", "--services-path=/services", "Change the services path") do |w|
    OPTIONS[:services_path] =  w if w != nil
  end
  
  #reloadable services
  opts.on("-r", "--reloadable", "Services are reloaded on execution") do |r|
    OPTIONS[:reload] = true if r != nil
  end
  
  #log to file?
  opts.on("-f", "--logging", "Turn on logging to rubyamf_core/logs/rubyamf.log. (Note that fatal is the default log level)") do |f|
    OPTIONS[:log_file] = 'rubyamf_core/logs/rubyamf.log'
  end
  
  #log level
  opts.on("-l", "--loglevel=fatal", [:debug,:info,:warn,:error,:fatal,:none], "Changes the log level, (debug|info|warn|error|fatal|none)") do |l|
    OPTIONS[:log_level] = l if l != nil
  end
  
  #backtrace
  opts.on("-b", "--backtrace","Turn on exception backtracing to Flash. (See wiki.rubyamf.org for more info)") do |b|
    OPTIONS[:backtrace] = true
  end
  
  #net debug
  opts.on("-n", "--net-debug","Allow Net Connection debugger tracing (AMF0 only)") do |n|
    OPTIONS[:net_debug] = true
  end
  
  #daemonize
  opts.on('-d', "--daemon", "Daemonize webrick|lighttpd|mongrel. UNIX only") do |d|
    if(!is_windows)
      OPTIONS[:daemon] = true
    else
      STDOUT.puts "WEBrick will not run as a daemon on windows"
      STDOUT.puts "A solution for running as a service is being looked into"
    end
  end
  
  #help, toggle server starting
  opts.on_tail("-h", "--help", "Show this usage statement") do |h|
    puts opts
    OPTIONS[:start_server] = false
  end
end

begin
  opts.parse!(ARGV)
rescue Exception => e
  puts e, "", opts
  exit
end

require "server/#{OPTIONS[:server_type]}/start"