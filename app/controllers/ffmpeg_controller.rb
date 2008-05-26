class FfmpegController < ApplicationController
  
  def flv_to_mp3
    
    filename = params[:filename]
    worker_key = "#{filename}_#{Time.now.to_i.to_s}"  

    worker_args = {:worker_key => worker_key}
    
    MiddleMan.new_worker(:worker => :ffmpeg_worker, :job_key => worker_key, :data => worker_args) 
    MiddleMan.worker(:ffmpeg_worker, worker_key).start(filename)
    
    
    
    render :xml => worker_status(worker_key, "idle")
    
  end

  def status(worker = nil)
    
    worker_key = params[:worker] || worker
    worker_info = MiddleMan.worker(:ffmpeg_worker, worker_key ).ask_status
    
    render :xml => worker_status(worker_key, worker_info[:status])    
  end

protected
  def worker_status(worker_key, w_status= nil)
    status_worker = w_status || status(worker_key) 
    return "<response><worker>#{worker_key}</worker><worker_status>#{status_worker}</worker_status></response>"
  end
  
end
