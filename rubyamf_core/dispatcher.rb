#!/usr/local/bin/ruby
###############

##########################
# FastCGI Ruby dispatcher
# (C) Derrick Pallas
#
# Authors: Derrick Pallas
# Website: http://derrick.pallas.us/ruby-cgi/
# License: Academic Free License 2.1
# Version: 2005-12-23a
#
#--

require 'rubygems'
require 'fcgi'
require 'mmap'

maxscripts = 128
maxscripts.freeze

class Script
  attr_accessor :map
  attr_accessor :mod
  attr_accessor :use
end

scripts = {}
mytime  = File.stat(__FILE__).mtime

def getBinding(cgi,env)
  return binding
end

FCGI.each_cgi do |cgi|
  script = cgi.env_table['SCRIPT_FILENAME']
  script.freeze

  begin
    if ( not scripts.key?script or scripts[script].mod < File.stat(script).mtime )
      if scripts.key?script
        scripts[script].map.munmap
      else
        scripts[script] = Script.new
      end
      scripts[script].mod = File.stat(script).mtime
      scripts[script].map = Mmap.new script, 'r'
    end
    scripts[script].use = Time.now

    Dir.chdir( File.dirname(script) )
    eval scripts[script].map, getBinding(cgi,cgi.env_table) if scripts[script].map

    if scripts.length > maxscripts
      begin
        killme = scripts.min { |a,b| a[1].use <=> b[1].use } [0]
        scripts[killme].map.munmap
        scripts.delete(killme)
      rescue Exception
      end
    end

  rescue Exception => bang
    #puts '<hr><b>Exception:</b>', '<em>', CGI::escapeHTML(bang), '</em>\n'
  end if (script && File.stat(script).readable?)

  if (File.stat(__FILE__).mtime > mytime)
    Process.kill 'SIGHUP', Process.pid
    mytime = File.stat(__FILE__).mtime
  end
end