$: << "mixer/"
require "mixer/tracklist"
require "mixer/track"

class SoxController < ApplicationController

  
  def export_song
    doc_line = "<song><track><filename>uno.mp3</filename><volume>0.5</volume><loop>0</loop><balance>-0.2</balance></track><track><filename>due.mp3</filename><volume>0.1</volume><loop>0</loop><balance>0</balance><time_shift>0</time_shift></track></song>"
        
    user_id = params[:user]
    output_name = "#{params[:user]}_#{Time.now.to_i.to_s}"
    #tracklist = Tracklist.new(params[:song], output_name)
    tracklist = Tracklist.new(doc_line, output_name)
    
    # aspetto che la tracklist finisca...
    while tracklist.running?
      sleep 2
    end
    
    
    # ho i comandi, faccio partire il worker
    run_sox_worker(tracklist.commands, user_id)        
  end
  
  def status(worker = nil)
    
    worker_key = params[:worker] || worker
    worker_info = MiddleMan.worker(:sox_worker, worker_key ).ask_status
    
    render :xml => worker_status(worker_key, worker_info[:status])    
  end

  
  
protected
  def run_sox_worker(commands, user_id)        
    
    worker_key = "#{user_id.to_s}_#{Time.now.to_i.to_s}"  

    worker_args = {:worker_key => worker_key, :output_name => @output_name}
    
    MiddleMan.new_worker(:worker => :sox_worker, :job_key => worker_key, :data => worker_args) 
    
    
    
    MiddleMan.worker(:sox_worker, worker_key).start(commands)
    
    render :xml => worker_status(worker_key, "idle")
    
  end
  
  def worker_status(worker_key, w_status= nil)
    status_worker = w_status || status(worker_key) 
    return "<response><worker>#{worker_key}</worker><worker_status>#{status_worker}</worker_status></response>"
  end


end
