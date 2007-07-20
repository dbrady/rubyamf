#This Install script is for Rails Plugin Installation. If using the RubyAMF standalone this is not needed.
begin
  require 'fileutils'
  FileUtils.copy_file("./vendor/plugins/rubyamf/rubyamf_core/app/rubyamf_controller.rb","./app/controllers/rubyamf_controller.rb",false)
  
  mime = true
  File.open("./config/environment.rb","r") do |f|
    while line = f.gets
      if line.match(/application\/x-amf/)
        mime = false
      end
    end
  end
  
  if mime == true
    File.open("./config/environment.rb","a") do |f|
      f.puts "\nMime::Type.register \"application/x-amf\", :amf"
    end
  end
rescue Exception => e
  puts "ERROR INSTALLING RUBYAMF: " + e.message
end