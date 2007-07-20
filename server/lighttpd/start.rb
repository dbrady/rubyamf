#Copyright (c) 2007 Aaron Smith (aaron@rubyamf.org) - MIT License

#start script for LightTPD

require 'server/support/silencer'
require 'server/support/token_parser'
require 'server/support/marshal_startup'

if (PLATFORM.include?('mswin') && silence_stderr { system('lighttpd -version') } == false) ||  silence_stderr{`lighttpd -version`} == ''
  STDOUT.puts "LightTPD is required, you don't have it installed"
  exit(1)
end

#make sure one of two configs
if(OPTIONS[:lighttpd_config] != 'aspawn' && OPTIONS[:lighttpd_config] != 'forward')
  OPTIONS[:lighttpd_config] = 'aspawn'
  STDOUT.puts "You can only specify aspawn or forward as a lighttpd config, using the default aspawn."
end

config_data = ''

#open the targeted config file
File.open("server/#{OPTIONS[:server_type]}/#{OPTIONS[:lighttpd_config]}.conf") do |f|
  while line = f.gets
    config_data << line
  end
  TokenParser.parse_tokens(OPTIONS, config_data)
end

#now write / overwrite newly created config file
File.open("rubyamf_core/tmp/configs/lighttpd/aspawn.conf", 'w') do |f|
  f.puts config_data
end

if(OPTIONS[:start_server])
  
  STDOUT.puts "Port: #{OPTIONS[:port]}"
  STDOUT.puts "Binding IP: #{OPTIONS[:ip]}" if OPTIONS[:ip] != nil
  STDOUT.puts "Processes: #{OPTIONS[:processes]}"
  STDOUT.puts "NetDebug.Trace is on" if OPTIONS[:net_debug] != false
  STDOUT.puts "Exception Backtracing to Flash is on" if OPTIONS[:backtrace] == true
  MarshalStartup.save_startup_options(OPTIONS)
  STDOUT.puts "Booting LightTPD..."
  
  #start the server
  if(!OPTIONS[:daemon])
     STDOUT.puts "Press CTRL + C to kill..."
    `lighttpd -f rubyamf_core/tmp/configs/lighttpd/aspawn.conf -D`
  else
    `lighttpd -f rubyamf_core/tmp/configs/lighttpd/aspawn.conf`
  end
end