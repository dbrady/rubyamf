#Copyright (c) 2007 Aaron Smith (aaron@rubyamf.org) - MIT License

#start script for WEBrick

require 'server/webrick/webrick_servlet'

#start the server
if(OPTIONS[:start_server])
  if(OPTIONS[:daemon])
    OPTIONS[:server_type] = WEBrick::Daemon
  else
    OPTIONS[:server_type] = WEBrick::SimpleServer
  end
  
  STDOUT.puts "Port: #{OPTIONS[:port]}"
  STDOUT.puts "Binding IP: #{OPTIONS[:ip]}" if OPTIONS[:ip] != nil
  STDOUT.puts "Gateway: #{OPTIONS[:gateway]}"
  STDOUT.puts "Services path: #{RUBYAMF_SERVICES}"
  STDOUT.puts "NetDebug.Trace is on" if OPTIONS[:net_debug] != false
  STDOUT.puts "Reloading Services" if OPTIONS[:reload]
  STDOUT.puts "Use -h for more configuration options\n\n"
  STDOUT.puts "=> Booting WEBrick Servlet"
  if !OPTIONS[:daemon] then STDOUT.puts "CTRL + C to kill" end
  
  server = WEBrick::HTTPServer.new(
    :Port	=> OPTIONS[:port],
    :DocumentRoot	=> OPTIONS[:working_dir] + '/public/',
    :ServerType => OPTIONS[:server_type],
    :BindAddress => OPTIONS[:ip]
  )
  
  server.mount(OPTIONS[:gateway], RUBYAMF::WEBrickServlet)
  trap "INT" do server.shutdown end
  server.start
end