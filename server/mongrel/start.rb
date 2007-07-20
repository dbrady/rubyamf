#Copyright (c) 2007 Aaron Smith (aaron@rubyamf.org) - MIT License

#start script for Mongrel

require 'server/mongrel/mongrel_servlet'

#start the server
if(OPTIONS[:start_server])
  STDOUT.puts "Port: #{OPTIONS[:port]}"
  STDOUT.puts "Binding IP: #{OPTIONS[:ip]}" if OPTIONS[:ip] != nil
  STDOUT.puts "Processes: #{OPTIONS[:processes]}"
  STDOUT.puts "Gateway: #{OPTIONS[:gateway]}"
  STDOUT.puts "Services path: #{RUBYAMF_SERVICES}"
  STDOUT.puts "NetDebug.Trace is on" if OPTIONS[:net_debug] != false
  STDOUT.puts "Reloading Services" if OPTIONS[:reload]
  STDOUT.puts "Use -h for more configuration options\n\n"
  STDOUT.puts "=> Booting Mongrel Servlet"
  if !OPTIONS[:daemon] then STDOUT.puts "CTRL + C to kill" end
  
  config = Mongrel::Configurator.new(:host => OPTIONS[:ip], :cwd => Dir.pwd, :log_file => '/rubyamf_core/logs/mongrel.log', :processes => OPTIONS[:processes]) do
    if OPTIONS[:daemon]
      daemonize
    end
    listener :port => OPTIONS[:port] do
      uri("/gateway.rb", :handler => RUBYAMF::MongrelServlet.new)
    end
  end
  config.run.join
end