

class DiscoverService
  
  #Notifies the browser that the Discovery Service is available
  def ping
    true
  end
  
  #Returns a dataprovider that can be directly given to a Tree component.
  #One "item" contains {method,parameters,comments,qualifiedPath,filename,classname,}
  def refresh
    
  end
  
end