WorkerKeyRegExp = /[\da-fA-F]{32}/
ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  map.root :controller => "main"

  map.connect '/encode_flv/:filename',      :controller => 'ffmpeg', :action => 'index', :filename => /[\w\d\.]+/
  map.connect '/encode_flv/status/:worker', :controller => 'ffmpeg', :action => 'status', :worker => WorkerKeyRegExp

  map.connect '/mix',                       :controller => 'sox',    :action => 'index', :conditions => { :method => :post }
  map.connect '/mix/status/:worker',        :controller => 'sox',    :action => 'status', :worker => WorkerKeyRegExp

  map.connect '/upload',                    :controller => 'upload', :action => 'index', :conditions => { :method => :post }
  map.connect '/upload/status/:worker',     :controller => 'upload', :action => 'status', :worker => WorkerKeyRegExp

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  #map.connect ':controller/service.wsdl', :action => 'wsdl'

  map.connect ':controller', :action => 'index'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
