WorkerKeyRegExp = /[\da-fA-F]{32}/
ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  map.root :controller => "main"

  map.encode        '/encode_flv',                :controller => 'ffmpeg', :action => 'index',  :conditions => { :method => :post }
  map.encode_status '/encode_flv/status/:worker', :controller => 'ffmpeg', :action => 'status', :worker => WorkerKeyRegExp

  map.mix           '/mix',                       :controller => 'sox',    :action => 'index',  :conditions => { :method => :post }
  map.mix_status    '/mix/status/:worker',        :controller => 'sox',    :action => 'status', :worker => WorkerKeyRegExp

  map.upload        '/upload',                    :controller => 'upload', :action => 'index',  :conditions => { :method => :post }
  map.upload_status '/upload/status/:worker',     :controller => 'upload', :action => 'status', :worker => WorkerKeyRegExp

  map.connect ':controller', :action => 'index'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
